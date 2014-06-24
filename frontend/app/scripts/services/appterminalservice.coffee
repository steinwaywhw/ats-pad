'use strict'

angular.module('atsPadApp').factory 'appTerminalService', ($http, $timeout, appNotificationService, appUrlService) ->

	notifier = appNotificationService
	id = null
	ready = false

	options = 
		path: "/console"
		remote: null
		parent: null
		cols: 140
		rows: 19
		wait: 3 #seconds

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

			api = appUrlService.worker()
			@open(options)

			request = $http.get(api)
			
			request.success (remote, status) =>
				notifier.debug "got remote worker: #{remote}"
				options.remote = remote

				callback = => @connect(options)
				$timeout(callback, options.wait * 1000)
				ready = true

			request.error (data, status) ->
				notifier.error("failed to load worker address", data)

		isReady: () -> ready

		cmd: (cmd) -> 
			@term.emit("data", "#{cmd}\n")

		msg: (msg) -> 
			@term.write("#{msg}")
			@cmd("\n")

		### Terminal Client ###
		
		default: (opts) ->
			path                 : opts?.path ? "/console"
			remote               : opts?.remote ? "http://localhost:8080"
			reconnectionDelay    : opts?.reconnectionDelay ? 500
			reconnectionAttempts : opts?.reconnectionAttempts ? 20
			cols                 : opts?.cols ? 180
			rows                 : opts?.rows ? 30
			parent               : opts?.parent ? document.body;
			timeout              : opts?.timeout ? 10000
			focus                : opts?.focus ? false
			forceNew             : opts?.forceNew ? true 

		term: null
		socket: null

		open: (opts) ->
			if not @term?
				notifier.debug("opening terminal")
				opts = @default(opts)

				@term = new Terminal 
					cols: options.cols 
					rows: options.rows
					useStyle: true
					screenKeys: true

				@term.open(options.parent)	

		connect: (opts) ->
			notifier.debug("connecting to worker")
			opts = @default(opts)

			#opts.remote = "http://107.170.130.41:8023/?wid=worker:C920EE39F2567856EC46ED701F19A061:UFs9ydJdVFAGQU2E"

			@socket = io.connect opts.remote, 
				path                 : opts.path
				timeout              : opts.timeout
				reconnectionDelay    : opts.reconnectionDelay
				reconnectionAttempts : opts.reconnectionAttempts
				forceNew             : opts.forceNew 

			@socket.on 'connect', => 
				notifier.debug("connected")
				@unbind()
				@bind(opts)
				@cmd('\n')
				@cmd('clear')

		bind: (opts) ->
			notifier.debug("binding")
			@term.on 'data', (data) => @socket.emit 'data', data
			@socket.on 'data', (data) => @term.write(data)
			@socket.on 'reconnecting', (count) => @msg("Reconnecting: #{count}\n")
			@socket.on 'disconnect', => 
				@unbind()
				@socket.close()
				@socket = null
				@connect(opts)
			
		unbind: ->
			notifier.debug("unbinding")
			@term.removeAllListeners 'data'
			@socket.removeAllListeners 'data'

				#  connect: 1,
				# connect_error: 1,
				# connect_timeout: 1,
				# disconnect: 1,
				# error: 1,
				# reconnect: 1,
				# reconnect_attempt: 1,
				# reconnect_failed: 1,
				# reconnect_error: 1,
				# reconnecting: 1
	}





