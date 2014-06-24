'use strict'

angular.module('atsPadApp').directive 'appTerminal', (appContextService, appTerminalService) ->

	restrict: 'A'
	link: (scope, element, attrs) ->
		options =
			parent: $(element).get()
			cols: attrs?.cols
			rows: attrs?.rows
		toWatch = -> appContextService.isReady()
		toDo = (newv, oldv, scope) ->
			if (newv)
				appTerminalService.init attrs.id, options
		
		scope.$watch(toWatch, toDo)
