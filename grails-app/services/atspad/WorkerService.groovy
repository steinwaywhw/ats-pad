package atspad
import org.apache.commons.lang3.time.DateUtils
import javax.annotation.PostConstruct


class WorkerService {
	def dockerService
	def redisService
	def grailsApplication

	def config

	def timer = new Timer()

    @PostConstruct
    def init() {
        config = grailsApplication.config.atspad
    }


	// def getPort(portsInfo) {
	// 	assert portsInfo

	// 	portsInfo.each { key, value ->
	// 		if (key == "${this.workerGuestPort}/tcp"))
	// 			return value[0].HostPort
	// 	}
	// }
    
    def isRunning(wid) {
        log.info "check running for ${wid}"

        if (!redisService.exists(wid))
            return false

        def worker = getWorker(wid)
        if (dockerService.inspect(worker.cid, "running")) 
            return true

        log.warn "worker died: ${worker.cid}"
        redisService.del(wid)

        return false
    } 

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
        def wid = DockerWorker.generateId(sid, atspadid)

        log.info "starting worker - ${wid}"

        log.trace "checking worker existance"
        if (isRunning(wid)) {
            def worker = getWorker(wid)
            assert worker
            keepAlive(worker)

            return worker
        } 

        log.trace "creating new worker"
        def worker = new DockerWorker(sid:sid, atspadid:atspadid)
        worker.id = wid

        // check working dir existance
        log.trace "Checking working dir existance"
        assert (new File(cwd)).exists()

        // pull image
        log.trace "pulling worker image"
        assert config.worker.dockerTag
        dockerService.pull(config.worker.dockerTag)

        // run image
        def cid = dockerService.run([
            img: config.worker.dockerTag, 
            cmd: "bash ./run.sh",
            dir: ["${cwd}": config.worker.guestCwd],
            expose: config.worker.guestPort
        ])

        log.trace "worker container id ${cid}"
        sleep 3000
        assert cid 
        assert dockerService.inspect(cid, "running")

        // setup worker object
        worker.cid = cid
        worker.with {
            ip = dockerService.inspect(cid, "ipaddress")
            port = this.config.worker.guestPort
            lastActive = System.currentTimeMillis()
            mount = cwd
        }

        // save to redis
        def reply = redisService.hmset(worker.id, worker.properties.collectEntries { key, value -> [key.toString(), value.toString()] })
        log.trace "saving to redis - ${reply}"

        log.info "started ${worker}"
        return worker
    }

    /**
     * Stop and remove a worker container
     * @param  worker a DockerWorker instance
     * @return        
     */
    def stop(worker) {

    	log.info "stopping worker - ${worker.id}"

    	assert worker.cid && worker.id

    	// stop
    	dockerService.stop(worker.cid)

    	// remove container
    	log.trace "removing worker container"
    	dockerService.rm(worker.cid)

    	// deleting
    	def output = redisService.del(worker.id)
    	log.trace "removing redis record - ${output}"

        assert !dockerService.ps().contains(worker.cid)
    }

    def getWorker(sid, atspadid) {
    	assert sid 
    	assert atspadid 
    	
    	def id = DockerWorker.generateId(sid, atspadid)
        return getWorker(id)
    }
    
    /**
     * Get the worker object from redis. Make sure worker exists.
     * @param  wid worker id
     * @return     worker object
     */
    def getWorker(wid) {
        assert wid
        
        log.info "loading worker ${wid}"

    	assert redisService.exists(wid)
       
	    def record = redisService.hgetAll(wid)
        assert record

	    def worker = new DockerWorker(record)
	    worker.id = wid
	    
	    return worker
    }

    /**
     * Keep alive the worker
     * @param  worker worker to touch
     * @return        updated worker
     */
    def keepAlive(worker) {
        assert worker 

    	log.info "keep alive - ${worker.id}"

    	log.trace "checking existance"
    	assert worker.id
    	assert redisService.exists(worker.id)

    	log.trace "updating worker record"
    	worker.lastActive = System.currentTimeMillis()
    	assert !redisService.hset(worker.id, "lastActive", worker.lastActive.toString())

    	return worker
    }

    /**
     * Remove expired/died workers
     * @return workers removed
     */
    def cleanup(ttl) {
    	def wids = []

    	log.info "cleaning up workers"

    	redisService.withRedis { redis ->

    		log.trace "querying died/expired workers"
    		redis.keys("worker:*").each { key ->

    			// check due time
    			def date = Long.parseLong(redis.hget(key, "lastActive")) / 1000
    			def due = date + ttl
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

    		log.trace "stopping died/expired workers"
    		wids.each { wid ->
    		    def worker = getWorker(wid)
    			this.stop(worker)
                redisService.del(wid)
    		}
    	}

    	return wids
    }

    /**
     * Run cleanup every workerTtl seconds
     * @return TimerTask
     */
    def setupCleanUp(ttl) {
    	this.cleanup()
    	def task = this.timer.runAfter(ttl * 1000, {
    		this.setupCleanUp(ttl)
    	})
    	return task
    }
}
