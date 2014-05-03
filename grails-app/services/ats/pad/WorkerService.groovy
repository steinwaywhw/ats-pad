package ats.pad
import org.apache.commons.lang3.time.DateUtils
import javax.annotation.PostConstruct

@Transactional
class WorkerService {
	def dockerService
	def redisService
	def grailsApplication

	def workerRepo 
	def workerTag 
	def workerGuestPort
	def workerCwd
	def workerTtl

	def timer = new Timer()

    @PostConstruct
    def init() {
        workerRepo = grailsApplication.config.atspad.worker.repo
    	workerTag = grailsApplication.config.atspad.worker.tag
    	workerGuestPort = grailsApplication.config.atspad.worker.port
    	workerCwd = grailsApplication.config.atspad.worker.cwd
    	workerTtl = grailsApplication.config.atspad.worker.ttl
    }


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

    	log.trace "Starting new worker - worker:${sid}:${atspadid}"

    	// check existance
    	log.trace "Checking worker existance"
    	def worker = new DockerWorker(sid:sid, atspadid:atspadid)
    	worker.id = DockerWorker.generateId(sid, atspadid)
    	
    	// already up and running
    	if (redisService.exists(worker.id)) {
    		log.trace "Already up and running"
    		def worker = getWorker(worker.id)
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
    	log.trace "Building worker"
    	dockerService.build(repo.getPath(), this.workerTag)

    	// run image
    	def cid = dockerService.run(img=workerTag, cmd="bash", dir_h=cwd, dir_g=workerCwd)
    	log.trace "Running worker - ${cid}"
    	assert cid 
    	assert dockerService.inspect(cid, "running")

    	// setup worker object
    	worker.cid = cid
    	worker.with {
    		ip = dockerService.inspect(cid, "ipaddress")
    		port = workerGuestPort
    		lastActive = System.currentTimeMillis()
    	}

    	// save to redis
    	def reply = redisService.hmset(worker.id, worker.properties)
    	log.trace "Saving to redis - ${reply}"
    	//assert reply.contains("OK")

    	log.trace "Retuning new worker - ${worker.properties}"
    	return worker
    }

    /**
     * Stop and remove a worker container
     * @param  worker a DockerWorker instance
     * @return        
     */
    def stop(worker) {

    	log.trace "Stopping worker - ${worker?.id}"

    	assert worker?.cid && worker?.id

    	// stop
    	dockerService.stop(worker.cid)

    	// remove container
    	log.trace "Removing worker container"
    	dockerService.rm(worker.cid)

    	// deleting
    	def output = redisService.del(worker.id)
    	log.trace "Removing redis record - ${output}"
    }

    def getWorker(sid, atspadid) {
    	assert sid 
    	assert atspadid 
    	
    	def id = DockerWorker.generateId(sid, atspadid)
        return getWorker(id)
    }
    
    def getWorker(wid) {
        assert wid
        
        log.info "Loading worker ${id}"

    	if (!redisService.exists(id))
    		return null
    	else {
    	    def record = redisService.hgetall(id)
    	    def worker = new DockerWorker(record)
    	    worker.id = record.id
    	    
    	    return worker
    	}
    }

    /**
     * Keep alive the worker
     * @param  worker worker to touch
     * @return        updated worker
     */
    def keepAlive(worker) {
    	log.info "Keep alive - ${worker?.id}"

    	log.trace "Checking existance"
    	assert worker?.id
    	assert redisService.exists(worker.id)

    	log.trace "Updating worker record"
    	worker.lastActive = System.currentTimeMillis()
    	assert !redisService.hset(worker.id, "lastActive", worker.lastActive)

    	return worker
    }

    /**
     * Remove expired/died workers
     * @return workers removed
     */
    def cleanup() {
    	def wids = []

    	log.info "Cleaning up workers"

    	redisService.withRedis { redis ->

    		log.trace "Querying died/expired workers"
    		redis.keys("worker:*").each { key ->
    			// check due time
    			def date = redis.hget(key, "lastActive") / 1000
    			def due = date + this.workerTtl
    			if (System.currentTimeMillis() / 1000 > due) {
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
    		    def worker = getWorker(wid)
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
