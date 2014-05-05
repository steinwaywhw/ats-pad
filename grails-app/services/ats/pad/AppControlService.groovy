package ats.pad
import javax.annotation.PostConstruct

class AppControlService {
    def grailsApplication
    def dockerService
    def redisService
    
    def proxyGuestPort
    def proxyHostPort
    def redisGuestPort
    
    def redisCid
    def proxyCid
    
    @PostConstruct
    def init() {
        proxyGuestPort = grailsApplication.config.atspad.proxy.guestPort
        proxyHostPort = grailsApplication.config.atspad.proxy.hostPort
        redisGuestPort = grailsApplication.config.atspad.redis.guestPort
    }
    
    def startProxy() {
        assert redisCid
        log.info "Starting proxy server"

        dockerService.build(dockerService.getDockerRepo("bouncy").getCanonicalPath(), "atspad/bouncy")
        
        proxyCid = dockerService.run([
            img: "atspad/bouncy",
            cmd: "node index.js",
            env: [ATSPAD_REDIS_IP:grailsApplication.config.atspad.redis.guestIp, ATSPAD_REDIS_PORT:redisGuestPort],
            expose: [proxyGuestPort],
            port: ["${proxyGuestPort}":proxyHostPort]
        ])
        
        assert dockerService.inspect(proxyCid, "running")
        
        grailsApplication.config.atspad.proxy.guestIp = dockerService.inspect(proxyCid, "ipaddress")
    }
    
    def startRedis() {
        log.info "Starting redis server"
        
        dockerService.build(dockerService.getDockerRepo("redis").getCanonicalPath(), "atspad/redis")

        redisCid = dockerService.run([
            img: "atspad/redis",
            cmd: "redis-server"
        ])
        
        assert dockerService.inspect(redisCid, "running")
        
        grailsApplication.config.atspad.redis.guestIp = dockerService.inspect(redisCid, "ipaddress")
    }

    def registerApp() {
        def appIp = grailsApplication.config.atspad.app.ip 
        def appPort = grailsApplication.config.atspad.app.port 
        def map = [ip: appIp, port: appPort]

        log.info "Registering server at ${map}"

        redisService.hmset("server:app", map)
        assert redisService.hgetAll("server:app") == map 
    }
    
    def stopall() {
        dockerService.stopall()
        dockerService.rmall()
    }

}
