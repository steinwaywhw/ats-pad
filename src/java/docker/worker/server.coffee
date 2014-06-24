

http    = require 'http'
express = require 'express'
io      = require 'socket.io'
pty     = require 'pty.js'
termjs  = require 'term.js'



server = 
	term   : null
	buff   : []
	server : null
	room   : 'clients'
	termup : (opts) ->
		term_opts = 
			name : require('fs').existsSync('/usr/share/terminfo/x/xterm-256color') ? 'xterm-256color' : 'xterm'
			cols : opts?.cols ? 140
			rows : opts?.rows ? 19
			cwd  : opts?.cwd ? '/root/atspad'

		@term = pty.fork 'bash', ['--rcfile', '/root/.bashrc'], term_opts

	binding: ->
		@term.on 'data', (data) => 
			if @server.engine.clientsCount isnt 0
				@server.sockets.in(@room).emit('data', data)
			else
				@buff.push(data)

		@server.on 'connection', (socket) =>
			socket.join @room
			socket.on 'data', (data) => @term.write(data)
			socket.on 'disconnect', () => socket.leave @room
				
			while @buff.length
				@server.sockets.in(@room).emit('data', @buff.shift())

	serverup: (opts) ->
		app = express()
		httpserver = http.createServer(app)

		app.use(express.static(__dirname))
		app.use(termjs.middleware())

		httpserver.listen(opts?.port ? 8023)

		server_opts = 
			path: opts?.path ? "/console"
			log: true

		@server = new io(httpserver, server_opts)

	run: (opts) ->
		@termup opts 
		@serverup opts 
		@binding()

module.exports = server;