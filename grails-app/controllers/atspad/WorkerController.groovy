package atspad
import grails.converters.*
import groovy.json.*
import javax.annotation.PostConstruct


class WorkerController {
	def grailsApplication
	def workerService
	def workspaceService
	def redisService
	
	def config 
	
	@PostConstruct
	void postInit() {
        this.config = this.grailsApplication.config.atspad
	}

	def cleanup() {
		log.info "clean up workers"
		workerService.cleanup(config.worker.ttl)
	}

	def start() {
		assert params.wid
		if (redisService.exists(wid)) {
			log.info "starting ${wid}"
			def worker = workerService.getWorker(wid)
			workerService.start(worker.mount, worker.sid, worker.atspadid)
		}

		log.info "worker not existed"
		render ""
	}

	def stop() {
		assert params.wid
		if (redisService.exists(wid)) {
			log.info "stopping ${wid}"
			def worker = workerService.getWorker(wid)
			workerService.stop(worker)
		}

		log.info "worker not existed"
		render ""
	}

	def keepAlive() {
		assert params.wid
		if (redisService.exists(wid)) {
			log.info "keep alive ${wid}"
			def worker = workerService.getWorker(wid)
			workerService.keepAlive(worker)
		}

		log.info "worker not existed"
		render ""
	}

	def inspect() {
		assert params.wid
		if (redisService.exists(wid)) {
			log.info "inspecting ${wid}"
			def worker = workerService.getWorker(wid)
			render dockerService.inspect(worker.cid) as JSON
		}

		log.info "worker not existed"
		render ""
	}
   
}
