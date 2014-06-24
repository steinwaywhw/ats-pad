

server = 
	term   : null
	buff   : []
	primus : null

	testOpts: ->
		cols        : 140
		rows        : 19
		cwd         : './'
		pathname    : "/console"
		transformer : "engine.io"
		timeout     : false
		port        : 8223

	upTerm: (opts) ->
		term_opts = 
			name : require('fs').existsSync('/usr/share/terminfo/x/xterm-256color') ? 'xterm-256color' : 'xterm'
			cols : opts?.cols ? 140
			rows : opts?.rows ? 19
			cwd  : opts?.cwd ? '/root/atspad'

		@term = require('pty.js').fork 'bash', ['--rcfile', '/root/.bashrc'], term_opts

	upServer: (opts) ->
		@primus = require('primus').createServer
			pathname    : opts?.pathname ? "/primus"
			transformer : opts?.transformer ? "engine.io"
			timeout     : opts?.timeout ? 35000
			port        : opts?.port ? 8023

		@primus.save "#{__dirname}/primus.js"

		@term.on "data", (data) =>
			if @primus.connected is 0
				@buff.push(data)
			else
				@primus.write(data)

		@primus.on "connection", (spark) =>

			while @buff.length
				@primus.write(@buff.shift())

			spark.on 'data', (data) =>
				@term.write(data)

	up: (opts) ->
		opts = @testOpts()
		@upTerm(opts)
		@upServer(opts)

server.up()
		

