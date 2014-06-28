package atspad
import javax.annotation.PostConstruct
import grails.converters.*
import groovy.json.*


class AppControlService {
    def grailsApplication
    def dockerService
    def redisService
    def workerService
    
    def config
    
    def redisCid
    def proxyCid
    
    @PostConstruct
    void postInit() {
        this.config = this.grailsApplication.config.atspad
        log.info "starting application with ${config as JSON}"
    }

    def startWorkerCleanUp() {
        log.info "setting up worker clean up routine with interval ${config.worker.ttl} seconds"
        workerService.setupCleanUp(config.worker.ttl)
    }

    def getServerIp() {
        def output = "ip route show dev eth0".execute().getText()
        return output.tokenize(" ")[9]
    }
    
    def startProxy() {
        assert redisCid
        assert config.proxy.dockerTag
        assert config.redis.guestIp
        assert config.redis.guestPort
        assert config.proxy.guestPort 
        assert config.proxy.hostPort

        log.info "starting proxy server"

        dockerService.pull(config.proxy.dockerTag)
        
        proxyCid = dockerService.run([
            img: config.proxy.dockerTag,
            cmd: "node index.js",
            env: [
                ATSPAD_REDIS_IP: config.redis.guestIp, 
                ATSPAD_REDIS_PORT: config.redis.guestPort,
                ATSPAD_PROXY_PORT: config.proxy.guestPort],
            expose: [config.proxy.guestPort],
            port: ["${config.proxy.guestPort}":config.proxy.hostPort]
        ])
        
        sleep 3000
        assert dockerService.inspect(proxyCid, "running")
        log.trace "proxy container id ${proxyCid}"

        config.proxy.guestIp = dockerService.inspect(proxyCid, "ipaddress")

        log.info "started: ${config.proxy.guestIp}"
    }
    
    def startRedis() {
        log.info "starting redis server"
        assert config.redis.dockerTag
        assert config.redis.guestPort 

        dockerService.pull config.redis.dockerTag

        redisCid = dockerService.run([
            img: config.redis.dockerTag,
            cmd: "bash ./run.sh",
            expose: config.redis.guestPort
        ])
        
        sleep 3000
        assert dockerService.inspect(redisCid, "running")
        log.trace "redis container id ${redisCid}"
        
        config.redis.guestIp = dockerService.inspect(redisCid, "ipaddress")

        log.info "started: ${config.redis.guestIp}"
    }

    def registerApp() {
        // def appIp = grailsApplication.config.atspad.app.ip 
        // appIp = dockerService.checkLoopbackAndTranslate(appIp)

        // def appPort = grailsApplication.config.atspad.app.port 
        // def map = [ip: appIp, port: appPort]

        // log.info "Registering server at ${map}"

        // redisService.hmset("server:app", map)
        // assert redisService.hgetAll("server:app") == map 
    }
    
    def stopall() {
        dockerService.stopall()
        dockerService.rmall()
    }

}
