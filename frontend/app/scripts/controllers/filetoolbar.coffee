'use strict'

angular.module('atsPadApp').controller 'FiletoolbarCtrl', ($scope, appContextService, appFileService, appPadService, appUrlService) ->

	$scope.add = ->
		$scope.pad.filenames.push("")
		$scope.pad.filecontents.push("")
		appFileService.select($scope.pad.filenames.length - 1)
		appFileService.edit(true)

	$scope.refresh = ->
		if appContextService.isReady()
			appPadService.syncToClient (pad) ->
				$scope.pad.filenames = pad.filenames
				$scope.pad.filecontents = pad.filecontents

	$scope.isEditing = -> appFileService.isEditing()
	
	$scope.download = -> appUrlService.downloadLink()