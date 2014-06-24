'use strict'

angular.module('atsPadApp').factory 'appContextService', (appNotificationService) ->
	
	notifier = appNotificationService
	id = null
	status = false

	# Public API here
	{
		reset: -> 
			notifier.debug "reseting context"
			id = null
			status = false

		getId: -> id 
		setId: (v) -> 
			id = v
			notifier.debug "setting context id: #{v}"
			
		ready: -> status = true
		isReady: -> status
	}
