'use strict'

angular.module('atsPadApp').constant 'appTermClient', 

	default: (options) ->
		path                      : options?.path ? "/console"
		remote                    : options?.remote ? "http://localhost:8080"
		#remote					  : "http://107.170.130.41:8023/?wid=worker:3B590B3BEC8FAA3906E7BEEFAFABDD4B:bTnmkpX668vKZZFP"
		reconnection_delay        : options?.reconnection_delay ? 500
		max_reconnection_attempts : options?.max_reconnection_attempts ? 20
		cols                      : options?.cols ? 180
		rows                      : options?.rows ? 30
		parent                    : options?.parent ? document.body;
		connect_timeout           : options?.connect_timeout ? 10000
		focus                     : options?.focus ? false
		
	term: null
	socket: null
	
	open: (options) ->
		if not @term?
			console.log("OPENING")
			options = @default(options)
			@term = new Terminal 
				cols: options.cols 
				rows: options.rows
				useStyle: true
				screenKeys: true

			@term.open(options.parent)

	cleanup: ->
		console.log("CLOSING")
		
		if @socket?
			console.log("cleaning up socket")
			console.dir(@socket)
			@socket.close()
			delete @socket
			@socket = null
		if @term?
			console.log("cleaning up term")
			@term.destroy()
			delete @term
			@term = null
		
	run: (options) ->
		console.log("RUNNING")

		if not @term?
			@open(options)

		options = @default(options)

		#localStorage.debug = ""
		console.dir(io)
		socket = io.connect options.remote, 
			path                      : options.path
			connectTimeout            : options.connect_timeout
			reconnectionDelay         : options.reconnection_delay
			maxReconnectionAttempts   : 2
			forceNew				  : true 

		@socket = socket

		@term.write "Connecting to #{options.remote}\r\n"

		@term.on 'data', (data) =>
			socket.emit 'data', data
		socket.on 'data', (data) =>
			@term.write(data)

		socket.on 'reconnecting', (count) =>
			@term.write "Reconnecting: #{count}\r\n"

		socket.on 'reconnect_error', =>
			@term.write "Reconnection error \r\n"
			@cleanup()
			@run(options)

		socket.on 'reconnect_failed', =>
			@term.write "Reconnection failed\r\n"
			@cleanup()
			@run(options)
		
		socket.on 'error', =>
			@term.write "Connection error \r\n"
			@cleanup()
			@run(options)

		socket.on 'reconnect', =>
			@term.emit 'data', "\nclear\n"

		socket.on 'connect', =>
			@term.emit 'data', "\nclear\n"

		socket.on 'disconnect', =>
			@term.write "\r\nDisconnected\r\n"


