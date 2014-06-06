'use strict'

angular.module('atsPadApp').factory 'appUrlService', (appContextService) ->
    
    id = appContextService.getId()
    prefix = "/api/pad"

    {
    	show: "#{prefix}/#{id}"
    	create: "#{prefix}"
    	delete: "#{prefix}/#{id}"
    	syncToServer: "#{prefix}/#{id}/file"
    	syncToClient: "#{prefix}/#{id}/file"
    	forkApi: "#{prefix}/#{id}/fork"
    	downloadApi: "#{prefix}/#{id}/download"

    	forkLink: "/#{id}/fork"
    	downloadLink: "/#{id}/download"

    	worker: "#{prefix}/#{id}/worker"
    }
