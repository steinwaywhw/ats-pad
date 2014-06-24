'use strict'

angular.module('atsPadApp').factory 'appTerminalService', ($http, $timeout, appNotificationService, appUrlService) ->

	notifier = appNotificationService
	ready = false


	# Public API here
	{
		init: (idSelector, opts) ->
			notifier.debug "init terminal"
			ready = false


			opts = @default(opts)
			opts.parent = document.getElementById(idSelector)
			@open(opts)

			api = appUrlService.worker()
			request = $http.get(api)
			
			request.success (url, status) =>
				notifier.debug "got remote worker: #{url}"
				opts.url = url

				#opts.url = "http://107.170.130.41:8023/?wid=worker:54ADF33D09C279D839AA641DBE6983D6:LC59WEwml6UOOZwM"

				$.getScript @scriptUrl(opts.scriptId, url), () =>
					callback = => @connect(opts)
					$timeout(callback, opts.initDelay * 1000)
					ready = true
				
			request.error (data, status) ->
				notifier.error("failed to load worker address", data)

		scriptUrl: (id, workerUrl) ->
			a = $('<a>', href:workerUrl)[0]
			scriptUrl = "http://#{a.hostname}:#{a.port}/console/primus.js#{a.search}"
			return scriptUrl


		isReady: () -> ready

		cmd: (cmd) -> 
			@term.emit("data", "#{cmd}\n")

		msg: (msg) -> 
			@term.write("#{msg}\r\n")
			@cmd("")

		default: (opts) ->
			scriptId  : opts?.scriptId ? "primus"
			path      : opts?.path ? "/console"
			url       : opts?.url ? "http://localhost:8080"
			cols      : opts?.cols ? 180
			rows      : opts?.rows ? 30
			parent    : opts?.parent ? document.body
			initDelay : opts?.initDelay ? 3 #seconds

		### Terminal Client ###
		
		term: null
		primus: null

		open: (opts) ->
			if @term?
				@term.destroy()

			notifier.debug("opening terminal")
			opts = @default(opts)

			@term = new Terminal 
				cols: opts.cols 
				rows: opts.rows
				useStyle: true
				screenKeys: true

			@term.open(opts.parent)

			@term.on "data", (data) =>
				if @primus?
					@primus.write(data)

		connect: (opts) ->
			notifier.debug("connecting to worker")
			opts = @default(opts)

			if @primus? then @primus.end()

			@primus = Primus.connect opts.url 
			@primus.on "data", (data) => @term.write(data)
			@primus.on "open", () => @cmd("clear")
			@primus.on "error", () => @msg("error")
			@primus.on "reconnecting", () => @msg("reconnecting")
	}





