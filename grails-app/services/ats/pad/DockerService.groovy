package ats.pad
import groovy.json.*
import grails.transaction.Transactional
import org.springframework.core.io.ClassPathResource


@Transactional
class DockerService {

	def dockers = []
	def names = [:]
	def grailsApplication

	def repobase = grailsApplication.config.atspad.docker.repo

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

		if (tag)
			return "docker build -t ${tag} ${localpath}".execute().getText()
		else
			return "docker build ${localpath}".execute().getText()
	}

	/**
	 * List all (stop/running) container id's
	 * @return a list of container id's
	 */
	def ps() {
		def cids = []
		"docker ps -aq".execute().in.eachLine { line ->
			cids << line
		}

		return cids
	}

	/**
	 * Run an image
	 * @param  img         image tag
	 * @param  cmd=null    command to be run
	 * @param  name=null   optional container name
	 * @param  link_p=null parent's container name
	 * @param  link_c=null parent's alias referenced by the child
	 * @param  port_h=null host port to be bind
	 * @param  port_g=null guest port to be exposed
	 * @param  dir_h       host dir to be mount into guest
	 * @param  dir_g       guest dir to monut host dir
	 * @return             container id
	 */
    def run(args) {

    	assert args?.img

    	def c = "docker run -d"

    	if (args?.name)
    		c += " --name ${args?.name}"
    	if (args?.link_p && args?.link_g)
    		c += " --link ${args?.link_p}:${args?.link_c}"
    	if (args?.port_h && args?.port_g)
    		c += " -p ${args?.port_g}:${args?.port_h}"
    	if (args?.dir_h && args?.dir_g)
    		c += " -v ${args?.dir_h}:${args?.dir_g}"

    	c += " ${args.img} ${args?.cmd}"

    	def cid = c.execute().getText()
    	this.dockers << cid
    	if (name)
    		this.names << [name : cid]

    	return cid.trim()
    }

    /**
     * Stop a container no matter what
     * @param  cid the container's id
     * @return     stdout
     */
    def stop(cid) {
    	assert cid
    	"docker stop ${cid}".execute().getText()
    }

    /**
     * Stop all containers no matter what
     * @return a list of stopped container id's
     */
    def stopall() {
    	def result = []
    	this.ps().each { cid ->
    		result << this.stop(cid)
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
    	if (this.contains(cid)) {
    		dockers.remove(cid)
    		this.names.removeAll {key, value ->
    			value == cid
    		}
    	}

    	return "docker rm ${cid}".execute().getText()
    }

    /**
     * Remove all container no matter what
     * @return [description]
     */
    def rmall() {
    	def result = []
    	this.ps().each { cid ->
    		result << this.rm(cid)
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
    	return "docker rmi ${tag}".execute().getText()
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
