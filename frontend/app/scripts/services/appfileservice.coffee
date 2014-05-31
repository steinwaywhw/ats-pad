'use strict'

angular.module('atsPadApp')
  .factory 'appFileService', (appNotificationService) ->

	editing = []
	filenames = []
	active = 0
	
	modes = 
		"ace/mode/markdown" : [".*\\.md$", "readme.*"]
		"ace/mode/ats"      : [".*\\.[ds]ats$"]
		"ace/mode/c_cpp"    : [".*\\.[ch]$", ".*\\.[ch]ats$"]
		"ace/mode/java"     : [".*\\.java$"]
	

	notifier = appNotificationService
	
	# Public API here
	{
		init: (pad) ->
			notifier.debug "init file service"

			editing.length = 0
			for name in [0...pad.filenames.length] 
				editing.push(false)

			filenames = pad.filenames[..]
			active = 0

		isActive: (index) -> index is active
		isEditing: (index) -> editing[index]

		active: -> active
		select: (index) -> active = index
		edit: (index) -> editing[index] = true
		done: (index) -> editing[index] = false
		validate: (filename) ->
			result = false
			result = true if filename? and (1 <= filename.length <= 64) and /\w+/.test(filename)
			
			result

		guessMode: (filename) ->
			mode = "ace/mode/text"

			for key, patterns of modes
				for pattern in patterns
					if new RegExp(pattern, "i").test(filename)
						mode = key

			mode

		create: () ->
			filenames.push("")
			editing.push(true)
			active = filenames.length - 1

		remove: (index) ->
			if not @isReadme(index)
				filenames.splice(index, 1)
				editing.splice(index, 1)

				if active >= filenames.length
					active = filenames.length - 1

		isReadme: (index) -> /readme.*/i.test(filenames[index])

	}
