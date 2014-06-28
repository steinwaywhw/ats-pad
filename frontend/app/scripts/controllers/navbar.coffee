'use strict'

angular.module('atsPadApp').controller 'NavbarCtrl', ($scope, $location, appContextService) ->
	$scope.$watch (-> appContextService.getId()), (n, o, scope) -> scope.id = n
	$scope.isActive = (route) -> $location.path() is route

