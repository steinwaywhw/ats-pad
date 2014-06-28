package atspad
import grails.converters.*
import groovy.json.*
import javax.annotation.PostConstruct
import org.apache.commons.lang3.RandomStringUtils

class PadController {

	def grailsApplication
	def workerService
	def workspaceService
	def redisService
	
	def config 
	
	@PostConstruct
	void postInit() {
        this.config = this.grailsApplication.config.atspad
	}

    def create() { 
    	def id = RandomStringUtils.randomAlphanumeric(config.pad.idsize)
    	def pad = new Pad()
    	pad.id = id

        log.info "creating pad ${id}"
        pad.save(flush:true)

    	// def cwd = workspaceService.allocate(pad.id, pad.files)
    	// def worker = workerService.start(cwd.getCanonicalPath(), session.id, pad.id)

    	render pad.id 
    }

    def fork() {
        assert params.id

        log.info "forking pad ${params.id}"

        def oldpad = Pad.get(params.id)
        if (!oldpad)
            render(status: 404, text: 'Not Found');

        def newpad = oldpad.cloneWithoutId()
        newpad.id = RandomStringUtils.randomAlphanumeric(config.pad.idsize)
        newpad.save(flush:true)

        log.info "forked ${newpad.id}"

        // def cwd = workspaceService.allocate(newpad.id, newpad.files)
        // def worker = workerService.start(cwd.getCanonicalPath(), session.id, newpad.id)

        render newpad.id
    }

    
    def url() {
        assert params.id
        
        def wid = DockerWorker.generateId(session.id, params.id)
        def appIp = config.app.ip
        def proxyPort = config.proxy.hostPort
        def url = "http://${appIp}:${proxyPort}/?wid=${wid}"

        render url
    }
    
    def show() {
    	assert params.id

    	def pad = Pad.get(params.id)
    	if (!pad)
    	    render(status: 404, text: 'Not Found')

    	def cwd = workspaceService.allocate(params.id, pad.files)
    	def worker = workerService.start(cwd.getCanonicalPath(), session.id, params.id)

        log.info "showing ${pad as JSON}"
    	render pad as JSON
    }

    def delete() {
    	assert params.id

    	def pad = Pad.get(params.id)
    	if (!pad)
    	    render(status: 404, text: 'Not Found')
    	    
    	def worker = workerService.getWorker(session.id, pad.id)
    	assert pad && worker 

    	workerService.stop(worker)
    	workspaceService.reclaim(pad.id)

    	pad.delete(flush: true)
        log.info "deleted ${params.id}"

    	render ""
    }

    def syncToClient() {
    	assert params.id

        log.info "syncing to client ${params.id}"

    	def pad = Pad.get(params.id)
    	if (!pad)
    	    render(status: 404, text: 'Not Found')
    	    
    	def worker = workerService.getWorker(session.id, pad.id)
    	assert pad && worker

    	workerService.keepAlive(worker)

        def newfiles = workspaceService.collectFiles(pad.id)
        pad.files = newfiles
        pad.save()

    	render pad as JSON
    }

    def syncToServer() {
    	assert params.id 

        log.info "syncing to server ${params.id}"

    	def pad = Pad.get(params.id)
    	if (!pad)
    	    render(status: 404, text: 'Not Found')
    	    
    	pad.files = request.JSON.files
    	pad.save()

        workspaceService.allocate(pad.id, pad.files);

    	render ""
    }

    def embed() {
        def id = params.id

        render(view: "/embed", model: [id: id])
    }


    def download() {
        assert params.id 

        log.info "downloading ${params.id}"
        def tar = workspaceService.zipFiles(params.id)

        render(file:tar, fileName:"atspad-${params.id}.tar.gz", contentType:'application/x-gzip')
    }

    def getFile() {
        assert params.id && params.name

        def pad = Pad.get(params.id)
        if (!pad && !pad.files[params.name])
            render(status: 404, text: 'Not Found')

        render pad.files[params.name]
    }

    def saveFile() {
        assert params.id && params.name

        def pad = Pad.get(params.id)
        if (!pad)
            render(status: 404, text: 'Not Found')

        def value = request.JSON

        pad.files[params.name] = value 
        pad.save(flush:true)

        render ""
    }

    def deleteFile() {
        assert params.id && params.name

        def pad = Pad.get(params.id)
        if (!pad && !pad.files[params.name])
            render(status: 404, text: 'Not Found')
        
        pad.files.remove(params.name)
        pad.save(flush:true)

        render ""
    }

}
