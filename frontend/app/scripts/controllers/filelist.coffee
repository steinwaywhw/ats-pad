'use strict'

angular.module('atsPadApp').controller 'FilelistCtrl', ($scope, $timeout, appFileService) ->
	
	$scope.isActive = (index) -> index is appFileService.active()
	$scope.isEditing = (index) -> appFileService.isEditing() && index is appFileService.active()
			

	$scope.onSelect = (index) -> 
		if index isnt appFileService.active()
			appFileService.select(index)
			appFileService.edit(false)

	$scope.isReadme = (filename) -> appFileService.isReadme(filename)
	$scope.onDelete = (index) -> 
		$scope.pad.filenames = (name for name, i in $scope.pad.filenames when i isnt index)
		$scope.pad.filecontents = (c for c, i in $scope.pad.filecontents when i isnt index)

	$scope.onEdit = -> appFileService.edit(true)
	$scope.onCancel = (index) -> 
		appFileService.edit(false)
		$scope.form.filenames[index] = $scope.pad.filenames[index]

	$scope.onSubmit = (index) -> 
		$scope.pad.filenames[index] = $scope.form.filenames[index]
		appFileService.edit(false)
		true


	# TODO
	$scope.validate = (filename, index) -> 
		if not appFileService.validate(filename)
			false
		else
			a = filename not in $scope.form.filenames[0...index]
			b = filename not in $scope.form.filenames[(index+1)..]

			a and b
	
	
