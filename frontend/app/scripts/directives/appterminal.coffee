'use strict'

angular.module('atsPadApp').directive 'appTerminal', (appTerminalService) ->

	restrict: 'A'
	link: (scope, element, attrs) ->
		options =
			parent: $(element).get()
			cols: attrs.cols?
			rows: attrs.rows?
			
		appTerminalService.init attrs.id, options

