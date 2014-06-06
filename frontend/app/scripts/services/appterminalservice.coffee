'use strict'

angular.module('atsPadApp').factory 'appTerminalService', ($http, $timeout, appTermClient, appNotificationService, appUrlService) ->

	notifier = appNotificationService
	id = null
	ready = false

	client = appTermClient

	options = 
		path: "console"
		remote: null
		parent: null
		cols: 140
		rows: 19
		wait: 10 #seconds

	# Public API here
	{
		init: (idSelector, opts) ->
			notifier.debug "init terminal"

			ready = false

			id = idSelector
			options.parent = document.getElementById(id)
			options.cols = opts.cols if opts?.cols?
			options.rows = opts.rows if opts?.rows?
			options.wait = opts.wait if opts?.wait?

			api = appUrlService.worker
			request = $http.get(api)
			client.open(options)
			
			
			request.success (remote, status) ->
				notifier.debug "got remote worker"
				options.remote = remote

				callback = -> client.run(options)
				$timeout(callback, options.wait * 1000)
				ready = true

			request.error (data, status) ->
				notifier.error("failed to load worker address", data)

		isReady: () -> ready

		cmd: (cmd) -> 
			client.term.emit("data", "#{cmd}\n")

		msg: (msg) -> 
			client.term.write("\n\r#{msg}")
			@cmd("\n")
	}





