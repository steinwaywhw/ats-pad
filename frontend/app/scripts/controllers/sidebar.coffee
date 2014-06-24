'use strict'

angular.module('atsPadApp').controller 'SidebarCtrl', ($scope, $timeout, $location, appTerminalService, appNotificationService, appContextService, appPadService, appFileService) ->

	notifier = appNotificationService
	
	$scope.flags = {}

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

	getAtsFiles = ->
		files = (file for file in $scope.pad.filenames when /.*dats/i.test(file))
		return files.join(" ")

	getCurrentFileForTC = ->
		filename = $scope.pad.filenames[appFileService.active()];

		switch  
			when /.*dats/i.test(filename) then "-d #{filename}"
			when /.*sats/i.test(filename) then "-s #{filename}"
			else null
		
	$scope.run = ->
		notifier.debug "running"

		if (file for file in $scope.pad.filenames when /.*dats/i.test(file)).length is 0
			appTerminalService.msg "No files to run."
		else
			flags = ""
			flags += ' -DATS_MEMALLOC_LIBC' if $scope.flags.ATS_MEMALLOC_LIBC
			
			appTerminalService.cmd("patscc #{getAtsFiles()} #{flags}")
			appTerminalService.cmd("./a.out")

	$scope.typecheck = ->
		if not getCurrentFileForTC()?
			appTerminalService.msg "Can't type check current file: #{$scope.pad.filenames[appFileService.active()]}"
		else
			appTerminalService.cmd "patsopt -tc #{getCurrentFileForTC()}"
		