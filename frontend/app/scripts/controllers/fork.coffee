'use strict'

angular.module('atsPadApp').controller 'ForkCtrl', ($location, $timeout, $scope, appNotificationService, $routeParams, appTerminalService, appPadService, appContextService) ->

	notifier = appNotificationService

	if not $routeParams.id? 
		notifier.error "no pad id present, can't fork"
	else
		notifier.debug "pad id #{$routeParams.id}, forking"
		appContextService.reset()
		appContextService.setId($routeParams.id)
		appPadService.fork (id) ->
			appContextService.reset()
			$timeout -> $location.path("/#{id}")



