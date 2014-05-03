class BootStrap {
    def appControlService
    
    def init = { servletContext ->
        appControlService.startRedis()
        appControlService.startProxy()
        
    }
    def destroy = {
        appControlService.stopall()
    }
}
