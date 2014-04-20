package ats.pad
import org.apache.commons.lang3.time.DateUtils
import grails.transaction.Transactional

@Transactional
class WorkerService {
	def dockerService
	def redisService
	def grailsApplication

	def workerRepo = grailsApplication.config.atspad.worker.repo
	def workerTag = grailsApplication.config.atspad.worker.tag
	def workerGuestPort = grailsApplication.config.atspad.worker.port
	def workerCwd = grailsApplication.config.atspad.worker.cwd
	def workerTtl = grailsApplication.config.atspad.worker.ttl

	def timer = new Timer()

	// def getPort(portsInfo) {
	// 	assert portsInfo

	// 	portsInfo.each { key, value ->
	// 		if (key == "${this.workerGuestPort}/tcp"))
	// 			return value[0].HostPort
	// 	}
	// }

	/**
	 * Build and run a worker docker privately. 
	 * No port will be published. Worker shouldn't 
	 * already exist.
	 * @param  cwd      the working dir to be mounted
	 * @param  sid      the session id 
	 * @param  atspadid 
	 * @return          a DockerWorker instance
	 */
    def start(cwd, sid, atspadid) {

    	log.trace "==================================="
    	log.trace "Starting new worker - worker/${sid}/${atspadid}"
    	log.trace "==================================="

    	// check existance
    	log.trace "Checking worker existance"
    	def worker = new DockerWorker(sid:sid, atspadid:atspadid, id:DockerWorker.generateId(sid, atspadid))
    	
    	// check running
    	if (redisService.exists(worker.id)) {
    		log.trace "Already up and running"
    		worker = new DockerWorker(redis.hgetall(wid))
    		keepAlive(worker)
    		return worker
    	}

    	// check working dir existance
    	log.trace "Checking working dir existance"
    	assert (new File(cwd)).exists()

    	// check repo existance
    	log.trace "Checking repo existance"
    	def repo = dockerService.getDockerRepo("worker")
    	assert repo.exists()

    	// build image
    	log.trace "Building image"
    	def output = dockerService.build(repo.getPath(), this.workerTag)
    	log.trace output
    	assert output.contains("Successfully built")

    	// run image
    	def cid = dockerService.run(img=workerTag, cmd="bash", dir_h=cwd, dir_g=workerCwd)
    	log.trace "Running image - ${cid}"
    	assert cid 
    	assert dockerService.inspect(cid, "running")

    	// setup worker object
    	worker.cid = cid
    	worker.with {
    		ip = dockerService.inspect(cid, "ipaddress")
    		port = workerGuestPort
    		lastActive = new Date()
    	}

    	// save to redis
    	def reply = redisService.hmset(worker.id, worker.properties)
    	log.trace "Saving to redis - ${reply}"
    	assert reply.contains("OK")

    	log.trace "Retuning new worker - ${worker.properties}"
    	return worker
    }

    /**
     * Stop and remove a worker container
     * @param  worker a DockerWorker instance
     * @return        
     */
    def stop(worker) {

    	log.trace "==================================="
    	log.trace "Stopping worker - ${worker?.id}"
    	log.trace "==================================="

    	assert worker?.cid && worker?.id

    	// stop
    	def output = dockerService.stop(worker.cid)
    	log.trace output

    	// remove container
    	output = dockerService.rm(worker.cid)
    	log.trace "Removing container - ${output}"

    	// deleting
    	output = redisService.del(worker.id)
    	log.trace "Removing redis record - ${output}"
    }

    def getWorker(sid, atspadid) {
    	assert sid 
    	assert atspadid 

    	def id = DockerWorker.generateId(sid, atspadid)

    	if (!redisService.exists(id))
    		return null
    	else 
    		return new DockerWorker(redisService.hgetall(id))
    }

    /**
     * Keep alive the worker
     * @param  worker worker to touch
     * @return        updated worker
     */
    def keepAlive(worker) {
    	log.trace "==================================="
    	log.trace "Keep alive - ${worker?.id}"
    	log.trace "==================================="

    	log.trace "Checking existance"
    	assert worker?.id
    	assert redisService.exists(worker.id)

    	log.trace "Updating worker record"
    	worker.lastActive = new Date()
    	assert !redisService.hset(worker.id, "lastActive", worker.lastActive)

    	return worker
    }

    /**
     * Remove expired/died workers
     * @return workers removed
     */
    def cleanup() {
    	def wids = []

    	log.trace "==================================="
    	log.trace "Cleaning up workers"
    	log.trace "==================================="

    	redisService.withRedis { redis ->

    		log.trace "Querying died/expired workers"
    		redis.keys("worker/*").each { key ->
    			// check due time
    			def date = parseToStringDate(redis.hget(key, "lastActive"))
    			def due = DateUtils.addSeconds(date, this.workerTtl)
    			if (new Date().after(due)) {
    				log.trace "expired - ${key}"
    				wids << key
    				return 
    			}

    			// check die
    			def cid = redis.hget(key, "cid")
    			if (!dockerService.inspect(cid, "running")) {
    				wids << key
    				log.trace "died - ${key}"
    			}
    		}

    		log.trace "Stopping died/expired workers"
    		wids.each { wid ->
    			def worker = new DockerWorker(redis.hgetall(wid))
    			this.stop(worker)
    		}
    	}

    	return wids
    }

    /**
     * Run cleanup every workerTtl seconds
     * @return TimerTask
     */
    def setupCleanUp() {
    	this.cleanup()
    	def task = this.timer.runAfter(workerTtl * 1000, {
    		this.setupCleanUp()
    	})
    	return task
    }
}
