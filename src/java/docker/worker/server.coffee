winston = require "winston"
papertrail = require "winston-papertrail"

winston.add winston.transports.Papertrail,
	host: 'logs.papertrailapp.com'
	port: 20895
	hostname: "worker"
	colorize: "true"

server = 
	term   : null
	buff   : []
	primus : null
	
	default: (opts) ->
		cols        : opts?.cols ? 140
		rows        : opts?.rows ? 19
		cwd         : opts?.cwd ? '/root/atspad'
		pathname    : opts?.pathname ? "/console"
		transformer : opts?.transformer ? "engine.io"
		timeout     : opts?.timeout ? false
		port        : opts?.port ? 8023

	upTerm: (opts) ->
		opts = @default(opts)
		winston.info("Bringing up terminal server.")
		term_opts = 
			name : require('fs').existsSync('/usr/share/terminfo/x/xterm-256color') ? 'xterm-256color' : 'xterm'
			cols : opts.cols
			rows : opts.rows
			cwd  : opts.cwd

		@term = require('pty.js').fork 'bash', ['--rcfile', '/root/.bashrc'], term_opts

	upServer: (opts) ->
		opts = @default(opts)
		winston.info("Bringing up pirmus")

		@primus = require('primus').createServer
			pathname    : opts.pathname 
			transformer : opts.transformer  
			timeout     : opts.timeout 
			port        : opts.port 

		@primus.save "#{__dirname}/primus.js"

		@term.on "data", (data) =>
			if @primus.connected is 0
				@buff.push(data)
			else
				@primus.write(data)

		@primus.on "connection", (spark) =>
			winston.info("New connection from %j %j", spark.address, spark.query, {})
			while @buff.length
				@primus.write(@buff.shift())

			spark.on 'data', (data) =>
				@term.write(data)

	up: (opts) ->
		opts = @default(opts)
		winston.info("Bringing up worker server with", opts)
		@upTerm(opts)
		@upServer(opts)

module.exports = server;