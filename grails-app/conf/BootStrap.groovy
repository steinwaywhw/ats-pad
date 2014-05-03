class BootStrap {
    def appControlService
    
    def init = { servletContext ->
        appControlServce.startRedis()
        appControlService.startProxy()
        
    }
    def destroy = {
        appControlService.stopall()
    }
}
