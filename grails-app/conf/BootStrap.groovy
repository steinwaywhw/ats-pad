class BootStrap {
    def appControlService
    def grailsApplication

    def init = { servletContext ->
        appControlService.startRedis()
        appControlService.registerApp()
        appControlService.startProxy()

    }
    def destroy = {
        appControlService.stopall()
    }
}
