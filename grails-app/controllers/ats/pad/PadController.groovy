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

        log.trace "${pad as JSON}"
    	render pad as JSON
    }
    
    def url() {
        assert params?.id
        
        def wid = DockerWorker.generateId(session.id, params.id)
        def proxyIp = grailsApplication.config.atspad.proxy.ip
        def proxyPort = grailsApplication.config.atspad.proxy.port 
        def url = "http://${proxyIp}:${proxyPort}/console?wid=${wid}"
        
        render url
    }
    
    def show() {
    	assert params.id

    	def pad = Pad.get(params.id)
    	if (!pad)
    	    render(status: 503, text: 'Not Found')

    	def cwd = workspaceService.reallocate(id, pad.files)
    	def worker = workerService.start(cwd.getCanonicalPath(), session.id, id)

        log.trace "${pad as JSON}"
    	render pad as JSON
    }

    def delete() {
    	assert params.id

    	def pad = Pad.get(params.id)
    	if (!pad)
    	    render(status: 503, text: 'Not Found')
    	    
    	def worker = workerService.getWorker(session.id, id)
    	assert pad && worker 

    	workerService.stop(worker)
    	workspaceService.reclaim(id)

    	pad.delete(flush: true)

    	render "OK" as JSON
    }

    def refresh() {
    	assert params.id

    	def pad = Pad.get(params.id)
    	if (!pad)
    	    render(status: 503, text: 'Not Found')
    	    
    	def worker = workerService.getWorker(session.id, id)
    	assert pad && worker

    	workerService.keepAlive(worker)

    	render pad.files as JSON
    }

    def upload() {
    	assert params.id 

    	def pad = Pad.get(params.id)
    	if (!pad)
    	    render(status: 503, text: 'Not Found')
    	    
    	pad.files = request.JSON
    	pad.save()

    	render "OK" as JSON
    }
}
