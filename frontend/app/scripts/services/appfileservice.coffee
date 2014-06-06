'use strict'

angular.module('atsPadApp').factory 'appFileService', (appNotificationService, $routeParams) ->

	active = 0
	editing = false

	modes = 
		"ace/mode/markdown" : [".*\\.md$", "readme.*"]
		"ace/mode/ats"      : [".*\\.[ds]ats$"]
		"ace/mode/c_cpp"    : [".*\\.[ch]$", ".*\\.[ch]ats$"]
		"ace/mode/java"     : [".*\\.java$"]


	notifier = appNotificationService
	
	# Public API here
	{
		active: -> active
		select: (index) -> active = index
		edit: (b) -> editing = b
		isEditing: -> editing

		validate: (filename) ->
			if not filename?
				false
			else
				/^[A-Za-z0-9_\.\-]+$/.test(filename) and filename.length <= 64


		guessMode: (filename) ->
			mode = "ace/mode/text"

			for key, patterns of modes
				for pattern in patterns
					if new RegExp(pattern, "i").test(filename)
						mode = key

			mode


		isReadme: (filename) -> /readme.*/i.test(filename)

	}
