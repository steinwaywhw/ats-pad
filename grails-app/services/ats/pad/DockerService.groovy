package ats.pad
import groovy.json.*
import org.springframework.core.io.ClassPathResource
import javax.annotation.PostConstruct
import java.net.InetAddress

class DockerService {

	def dockers = []
	def names = [:]
	def grailsApplication

	def repobase
	
	@PostConstruct
	def init() {
	    repobase = grailsApplication.config.atspad.docker.repo
	}

    def getDockerBridgeIp() {
        return "ip route show dev docker0".execute().getText().tokenize()[6]
    }

    def checkLoopbackAndTranslate(ip) {
        def addr = InetAddress.getByName(ip)
        return addr.isLoopbackAddress() ? getDockerBridgeIp() : ip  
    }

	/**
	 * Get the base dir for the dockerfile repo in
	 * the classpath. Can specify a specific repo name
	 * @param  name=null optional name for a specific repo
	 * @return           basedir for the repo
	 */
	def getDockerRepo(name=null) {
		def base = repobase
		if (name)
			base = "${base}/${name}"
		return new ClassPathResource(base).getFile()
	}

	/**
	 * Build the image of spcified basedir with optional tag
	 * @param  localpath the directory containing Dockerfile
	 * @param  tag=null  optional tag
	 * @return           stdout content
	 */
	def build(localpath, tag=null) {
		assert (new File(localpath)).exists()
		
		log.info "Building ${localpath} ${tag}"

        def stdout
		if (tag)
			stdout = "docker build -t ${tag} ${localpath}".execute().getText()
		else
			stdout = "docker build ${localpath}".execute().getText()
		
		log.trace stdout
		assert stdout.contains("Successfully built")
	}

	/**
	 * List all (stop/running) container id's
	 * @return a list of container id's
	 */
	def ps() {
	    log.info "Docker ps"
	    
		def cids = []
		"docker ps -aq".execute().in.eachLine { line ->
			cids << line
			log.trace line
		}

		return cids
	}

	/**
	 * Run an image
	 * @param  img         image tag
	 * @param  cmd=null    command to be run
	 * @param  name=null   optional container name
	 * @param  link=[:]    link [parent:alias_as_in_child]
	 * @param  port=[:]    port mapping [guest:host]
	 * @param  dir=[:]     dir mounting [host:guest]
	 * @param  env=[:]     environment variable [name:value]
	 * @param  expose=[]   guest ports to be exposed
	 * @return             container id
	 */
    def run(args) {

    	assert args?.img
    	log.info "Running image ${args.img}"

    	def c = "docker run -d"

    	if (args?.name)
    		c += " --name ${args.name}"
    	if (args?.link)
    	    args.link.each { key, value ->
    	        c += " --link ${key}:${value}"
    	    }
    	if (args?.port)
    	    args.port.each { key, value ->
    	        c += " -p ${key}:${value}"
    	    }
    	if (args?.dir)
    	    args.dir.each { key, value -> 
    	        c += " -v ${key}:${value}"
    	    }
        if (args?.env)
            args.env.each { key, value ->
                c += " --env ${key}=${value}"
            }
        if (args?.expose)
            args.expose.each { value ->
                c += " --expose ${value}"
            }
        
    	c += " ${args.img} ${args?.cmd}"
    	
    	log.info c

    	def cid = c.execute().getText().trim()
    	assert inspect(cid, "running")
    	
    	this.dockers << cid
    	if (args?.name)
    		this.names << [(args.name) : cid]

    	return cid
    }

    /**
     * Stop a container no matter what
     * @param  cid the container's id
     * @return     stdout
     */
    def stop(cid) {
    	assert cid
    	log.info "Stopping ${cid}"
    	"docker stop ${cid}".execute().getText()
    	
    	return
    }

    /**
     * Stop all containers no matter what
     * @return a list of stopped container id's
     */
    def stopall() {
        log.info "Stopping all containers"
    	def result = []
    	this.ps().each { cid ->
    		result << this.stop(cid)
    		log.trace cid
    	}

    	return result
    }

    /**
     * Remove a container no matter what, and remove
     * it from {@link #dockers} and {@link #names} at the same time
     * @param  cid container id
     * @return     stdout
     */
    def rm(cid) {
    	assert cid
    	log.info "Removing container ${cid}"
    	
    	if (this.contains(cid)) {
    		dockers.remove(cid)
    		this.names = this.names.findAll { key, value ->
    			value != cid
    		}
    	}

    	log.trace "docker rm ${cid}".execute().getText()
    	return cid
    }

    /**
     * Remove all container no matter what
     * @return [description]
     */
    def rmall() {
        log.info "Removing all containers"
    	def result = []
    	this.ps().each { cid ->
    		result << this.rm(cid)
    		log.trace cid
    	}

    	return result
    }

    /**
     * Remove an image no matter what
     * @param  tag the tag of the image
     * @return     stdout
     */
    def rmi(tag) {
    	assert tag
    	log.info "Removing image ${tag}"
    	log.trace "docker rmi ${tag}".execute().getText()
    	return 
    }

    /**
     * Check if a container id is maintained by the DockerService
     * @param  cid container's full/partial id
     * @return     true if found, false if not
     */
    def contains(cid) {
    	assert cid

    	def found = false
    	this.dockers.each { fullcid ->
    		if (fullcid.contains(cid))
    			found = true
    	}
    	return found
    }

    /**
     * Inspect a container
     * @param  cid          the container id
     * @param  request=null optional requested info, null for complete info
     * @return              a json object containing the requested info
     */
    def inspect(cid, request=null) {

    	assert cid
    	log.info "Inspecting ${cid}"

    	def output = "docker inspect ${cid}".execute().getText()
    	def info = new JsonSlurper().parseText(output)[0]

    	if (!request)
    		return info;

    	def ret = ""
    	switch (request) {
    		case "ports":
    			ret = info.NetworkSettings.Ports
    			break
    		case "ipaddress": 
    			ret = info.NetworkSettings.IPAddress
    			break
    		case "name": 
    			ret = info.Name
    			break
    		case "id":
    			ret = info.ID 
    			break
    		case "hostname":
    			ret = info.Config.Hostname 
    			break
    		case "running":
    			ret = info.State.Running 
    			break
    	}

    	return ret 
    }
}
