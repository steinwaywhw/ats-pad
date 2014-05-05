class BootStrap {
    def appControlService
    def grailsApplication

    def init = { servletContext ->
        appControlService.startRedis()
        appControlService.startProxy()
        appControlService.registerApp()
        
    }
    def destroy = {
        appControlService.stopall()
    }
}
