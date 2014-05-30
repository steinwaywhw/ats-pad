package ats.pad
import grails.converters.*
import groovy.json.*
import javax.annotation.PostConstruct
import org.apache.commons.lang3.RandomStringUtils

class PadController {

	def grailsApplication
	def workerService
	def workspaceService
	def redisService
	
	def idSize
	
	@PostConstruct
	def init() {
	    idSize = grailsApplication.config.atspad.pad.idsize
	}
	

    def create() { 
    	def id = RandomStringUtils.randomAlphanumeric(idSize)
    	def pad = new Pad()
    	pad.id = id

    	def cwd = workspaceService.allocate(pad.id, pad.files)
    	def worker = workerService.start(cwd.getCanonicalPath(), session.id, pad.id)

    	pad.save()

    	render pad.id 
    }
    
    def url() {
        assert params.id
        
        def wid = DockerWorker.generateId(session.id, params.id)
        def appIp = grailsApplication.config.atspad.app.ip
        def proxyPort = grailsApplication.config.atspad.proxy.hostPort 
        def url = "http://${appIp}:${proxyPort}/?wid=${wid}"

        render url
    }
    
    def show() {
    	assert params.id

    	def pad = Pad.get(params.id)
    	if (!pad)
    	    render(status: 503, text: 'Not Found')

    	def cwd = workspaceService.reallocate(params.id, pad.files)
    	def worker = workerService.start(cwd.getCanonicalPath(), session.id, params.id)

        log.trace "${pad as JSON}"
    	render pad as JSON
    }

    def delete() {
    	assert params.id

    	def pad = Pad.get(params.id)
    	if (!pad)
    	    render(status: 503, text: 'Not Found')
    	    
    	def worker = workerService.getWorker(session.id, pad.id)
    	assert pad && worker 

    	workerService.stop(worker)
    	workspaceService.reclaim(id)

    	pad.delete(flush: true)

    	render ""
    }

    def refresh() {
    	assert params.id

    	def pad = Pad.get(params.id)
    	if (!pad)
    	    render(status: 503, text: 'Not Found')
    	    
    	def worker = workerService.getWorker(session.id, pad.id)
    	assert pad && worker

    	workerService.keepAlive(worker)

        def newfiles = workspaceService.collectFiles(pad.id)
        pad.files = newfiles
        pad.save()

    	render pad as JSON
    }

    def upload() {
    	assert params.id 

    	def pad = Pad.get(params.id)
    	if (!pad)
    	    render(status: 503, text: 'Not Found')
    	    
    	pad.files = request.JSON.files
    	pad.save()

        workspaceService.reallocate(pad.id, pad.files);

    	render ""
    }

    def embed() {
        def id = params.id

        render(view: "/embed", model: [id: id])
    }

    def fork() {
        assert params.id

        def oldpad = Pad.get(params.id)
        if (!oldpad)
            render(status: 503, text: 'Not Found');

        def newpad = oldpad.cloneWithoutId()
        newpad.id = RandomStringUtils.randomAlphanumeric(idSize)
        newpad.save()

        def cwd = workspaceService.allocate(newpad.id, newpad.files)
        def worker = workerService.start(cwd.getCanonicalPath(), session.id, newpad.id)


        render newpad.id
    }

}
