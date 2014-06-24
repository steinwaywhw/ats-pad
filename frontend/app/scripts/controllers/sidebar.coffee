'use strict'

angular.module('atsPadApp').controller 'SidebarCtrl', ($scope, $timeout, $location, appNotificationService, appContextService, appPadService) ->

	notifier = appNotificationService
	
	$scope.newpad = ->
		notifier.debug "creating new pad"
		appContextService.reset()
		$timeout -> $location.path("/")

	$scope.forkpad = ->
		notifier.debug "forking current pad"
		id = appContextService.getId()
		$timeout -> $location.path("/#{id}/fork")

	$scope.deletepad = ->
		notifier.debug "deleting pad"
		$timeout (-> $location.path("/")), 1000 * 1
		appPadService.delete ->
			notifier.success("Your pad has been deleted. Creating a new one ...")
