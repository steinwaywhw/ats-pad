'use strict'

angular.module('atsPadApp').directive 'appEditor', ($timeout, appFileService, appEditorService) ->

	id = null

	{
		restrict: 'AE'
		link: (scope, element, attrs) ->	
			id = attrs.id
			appEditorService.init(id) 
			service = appEditorService
			editor = appEditorService.getEditor()

			editorOnChange = ->
				editor = appEditorService.getEditor()
				editor.getSession().on "change", (e) ->
					$timeout ->
						active = appFileService.active()
						scope.pad.filecontents[active] = service.getText()

			activeFileToWatch = ->
				active = appFileService.active()
				scope.pad?.filecontents?[active]

			activeFileOnChange = (newv, oldv, scope) ->
				if newv?
					editor = appEditorService.getEditor()
					cursor = editor.getSelection().getCursor()
					top = editor.getSession().getScrollTop()
					service.setText(newv)
					editor.clearSelection()
					editor.moveCursorToPosition(cursor)
					editor.focus()
					editor.getSession().setScrollTop(top)
					
			modeToWatch = -> 
				active = appFileService.active()
				if scope.pad?.filenames?[active]
					appFileService.guessMode(scope.pad.filenames[active])
			modeOnChange = (newv, oldv, scope) ->
				if newv?
					service.setMode(newv)

			editor.getSession().on("change", editorOnChange)
			scope.$watch(activeFileToWatch, activeFileOnChange, true)
			scope.$watch(modeToWatch, modeOnChange, true)
			$(document).ready ->
				editor = appEditorService.getEditor()
				editor.clearSelection()
				editor.focus()
	}
				
