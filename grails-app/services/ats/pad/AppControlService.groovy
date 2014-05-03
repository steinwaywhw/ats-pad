package ats.pad
import javax.annotation.PostConstruct

class AppControlService {
    def grailsApplication
    def dockerService
    
    def proxyGuestPort
    def proxyHostPort
    def redisGuestPort
    
    
    @PostConstruct
    def init() {
        proxyGuestPort = grailsApplication.config.atspad.proxy.guestPort
        proxyHostPort = grailsApplication.config.atspad.proxy.hostPort
        redisGuestPort = grailsApplication.config.atspad.redis.guestPort
    }
    
    def startProxy() {
        
    }
    
    def startRedis() {
        
    }

}
