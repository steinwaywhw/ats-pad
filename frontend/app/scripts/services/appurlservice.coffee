'use strict'

angular.module('atsPadApp').factory 'appUrlService', (appContextService) ->
	
	id = -> appContextService.getId()
	prefix = "http://107.170.130.41:8080/api/pad"

	{
		show         : -> "#{prefix}/#{id()}"
		create       : -> "#{prefix}"
		delete       : -> "#{prefix}/#{id()}"
		syncToServer : -> "#{prefix}/#{id()}/file"
		syncToClient : -> "#{prefix}/#{id()}/file"
		fork         : -> "#{prefix}/#{id()}/fork"
		downloadApi  : -> "#{prefix}/#{id()}/download"
		
		downloadLink : -> "/#{id()}/download"
		
		worker       : -> "#{prefix}/#{id()}/worker"
		workerStart  : (wid) -> "#{prefix}/worker/${wid}/start"
		workerStop   : (wid) -> "#{prefix}/worker/${wid}/stop"
	}
