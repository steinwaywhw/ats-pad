'use strict'

angular.module('atsPadApp').factory 'appEditorService', (appNotificationService) ->
		
		notifier = appNotificationService 
		
		if not ace?
			notifier?.error "ace editor is not avaliable"

		id = null
		editor = null
		options = 
			useWorker               : false
			theme                   : "ace/theme/idle_fingers"
			useSoftTabs             : true
			showPrintMargin         : false
			vScrollBarAlwaysVisible : false
			useWrapMode             : true
			wrapLimitRange          : [null, null]

		# return
		{
			init: (idSelector) ->
				notifier.debug "init editor with #{idSelector}"

				editor = ace.edit(idSelector)
				id = idSelector

				session = editor.getSession()

				session.setUseWorker(options.useWorker)
				editor.setTheme(options.theme)
				editor.setAnimatedScroll(true)
				session.setUseSoftTabs(options.useSoftTabs)
				editor.setShowPrintMargin(options.showPrintMargin)
				editor.setOption("vScrollBarAlwaysVisible", options.vScrollBarAlwaysVisible)
				session.setUseWrapMode(options.useWrapMode)
				session.setWrapLimitRange(options.wrapLimitRange[0], options.wrapLimitRange[1])

				@setMode("ace/mode/markdown")


			getEditor: () -> editor

			getCursorStatus: () ->
				c = editor.getSelection().getSelectionLead()
				r = editor.getSelectionRange()

				{
					row: c.row + 1
					col: c.column + 1
					hasSel: not editor.selection.isEmpty()
					sel: {
						srow: r.start.row + 1
						scol: r.start.column + 1
						erow: r.end.row + 1
						ecol: r.end.column + 1
					}
				}

			setMode: (mode) ->
				editor.getSession().setMode(mode)

			setText: (text) ->
				editor.getSession().setValue(text)

			getText: () -> editor.getSession().getValue()
		}
