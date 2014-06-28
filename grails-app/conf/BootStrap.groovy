import grails.converters.*
import groovy.json.*


class BootStrap {
    def appControlService
    def grailsApplication

    def init = { servletContext ->

        appControlService.stopall()

        appControlService.startRedis()
        appControlService.startProxy()
        appControlService.startWorkerCleanUp()

        def config = grailsApplication.config.atspad
        config.app.ip = appControlService.getServerIp()
        config.app.url = "http://${config.app.ip}:${config.app.port}${config.app.context}"
        log.info "application started at ${config.app.url}"
        log.info "config: ${config as JSON}"
    }

    def destroy = {
        appControlService.stopall()
    }
}
