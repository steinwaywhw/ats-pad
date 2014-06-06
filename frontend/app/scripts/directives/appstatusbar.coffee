'use strict'

angular.module('atsPadApp').directive 'appStatusBar', (appEditorService, $timeout) ->
	
	
	templateUrl: 'views/partials/statusbar.html'
	scope: {}
	replace: false
	restrict: 'A'
	link: (scope, element, attrs) ->
		scope.bar = appEditorService.getCursorStatus()

		selection = appEditorService.getEditor().getSession().getSelection()

		selection.on "changeSelection", -> $timeout -> scope.bar = appEditorService.getCursorStatus()
		selection.on "changeCursor", -> $timeout -> scope.bar = appEditorService.getCursorStatus()
