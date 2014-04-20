package ats.pad
import grails.converters.*
import groovy.json.*

class PadController {

	def grailsApplication
	def workerService
	def workspaceService
	def redisService

    def create() { 

    	def id = RandomStringUtils.randomAlphanumeric(grailsApplication.config.atspad.pad.idsize)
    	def pad = new Pad(id: id)

    	def cwd = workspaceService.allocate(pad.id, pad.files)
    	def worker = workerService.start(cwd.getCanonicalPath(), session.id, pad.id)

    	pad.save()

    	render pad as JSON
    }

    def show() {
    	assert params.id

    	def pad = Pad.get(params.id)

    	def cwd = workspaceService.reallocate(id, pad.files)
    	def worker = workerService.start(cwd.getCanonicalPath(), session.id, id)

    	render pad as JSON
    }

    def delete() {
    	assert params.id

    	def pad = Pad.get(params.id)
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
    	def worker = workerService.getWorker(session.id, id)
    	assert pad && worker

    	workerService.keepAlive(worker)

    	render pad.files as JSON
    }

    def upload() {
    	assert params.id 

    	def pad = Pad.get(params.id)
    	pad.files = request.JSON

    	pad.save()

    	render "OK"
    }
}
