'use strict'

angular.module('atsPadApp').directive 'appLoading', (appContextService) ->

	templateUrl: 'views/partials/loading.html'
	restrict: 'A'
	replace: false
	scope: {}
	link: (scope, element, attrs) ->

		toWatch = -> appContextService.isReady()
		toDo = (newv, oldv, scope) ->
			if newv
				$(element).fadeOut('slow')
			else
				$(element).fadeIn('slow')

		scope.$watch(toWatch, toDo)
		


