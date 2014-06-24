'use strict'

angular.module('atsPadApp').controller 'NavbarCtrl', ($scope, appContextService) ->
	$scope.$watch (-> appContextService.getId()), (n, o, scope) -> scope.id = n