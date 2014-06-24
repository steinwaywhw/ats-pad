'use strict'

angular.module('atsPadApp').controller 'MainCtrl', ($scope, $location, $timeout, $routeParams, appNotificationService, appPadService, appContextService, appEditorService, testPad, appTerminalService) ->
	
	notifier = appNotificationService
	# $scope.pad = 
	# 	id: testPad.id 
	# 	filenames: testPad.filenames
	# 	filecontents: testPad.filecontents

	binding = () ->
		sync = (newv, oldv, scope) ->
			if appPadService.validate(newv)
				notifier.debug("saving")
				appPadService.syncToServer(newv)
			else 
				notifier.debug("not valid, cancel saving")

		$scope.$watch "pad", sync, true

	if not $routeParams.id? 
		notifier.debug "no pad id present, creating"
		appContextService.reset()
		appPadService.create (id) ->
			$timeout -> $location.path(id)
	else
		notifier.debug "pad id #{$routeParams.id}, loading"
		appContextService.reset()
		appPadService.show $routeParams.id, (pad) ->
			$scope.pad = pad 
			appContextService.setId(pad.id)
			appContextService.ready()

	binding()		



