'use strict'

angular.module('atsPadApp').constant 'appTermClient', 
	
	default: (options) ->
		path                      : options?.path ? "console"
		remote                    : options?.remote ? "http://localhost:8080"
		reconnection_delay        : options?.reconnection_delay ? 500
		max_reconnection_attempts : options?.max_reconnection_attempts ? 20
		cols                      : options?.cols ? 180
		rows                      : options?.rows ? 30
		parent                    : options?.parent ? document.body;
		connect_timeout           : options?.connect_timeout ? 10000
		focus                     : options?.focus ? false
		
	term: null
	
	open: (options) ->
		options = @default(options)
		term = new Terminal 
			cols: options.cols 
			rows: options.rows
			useStyle: true
			screenKeys: true
			
		term.open(options.parent)
		@term = term
		
	run: (options) ->
		if not @term?
			@openTerm(options)

		options = @default(options)
		localStorage.debug = "*"
		socket = io.connect options.remote, 
			'resource'                  : options.path
			'connect timeout'           : options.connect_timeout
			'reconnection delay'        : options.reconnection_delay
			'max reconnection attempts' : options.max_reconnection_attempts

		@term.on 'data', (data) ->
			socket.emit 'data', data
		socket.on 'data', (data) ->
			@term.write(data)

		socket.on 'connecting', ->
			@term.write "Connecting to #{options.remote}\r\n"
		socket.on 'reconnecting', ->
			@term.write "Reconnecting\r\n"
		socket.on 'disconnect', ->
			@term.write "\r\nDisconnected\r\n"
			@term.write "Reconnecting\r\n"
		socket.on 'error', ->
			@term.write "Connection error \r\n"
			@term.write "Reconnecting\r\n"
		socket.on 'reconnect_failed', ->
			@term.write "Connection failed\r\n"
			@term.write "Reconnecting\r\n"
		socket.on 'connect_failed', ->
			@term.write "Connection failed\r\n"
			@term.write "Reconnecting\r\n"
		
		socket.on 'reconnect', ->
			@term.emit 'data', "clear\n"
		socket.on 'connect', ->
			@term.emit 'data', "clear\n"
	
	
