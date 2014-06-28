
winston = require "winston"
redis = require "redis"
papertrail = require "winston-papertrail"

redis.debug_mode = false

winston.add winston.transports.Papertrail,
	host: 'logs.papertrailapp.com'
	port: 20895
	hostname: "bouncy"
	colorize: "true"
        

winston.exitOnError = false

proxy = 
	getRedis: ->
		if not process.env.ATSPAD_REDIS_IP?
			winston.error("Please specify ATSPAD_REDIS_IP")
		else
			ip: process.env.ATSPAD_REDIS_IP
			prot: process.env.ATSPAD_REDIS_PORT ? 6379

	onError: (res) ->
		res.statusCode = 500
		res.end('SORRY, SOMETHING IS WRONG!')

	init: ->
		winston.info("Initializing proxy server.")
		winston.info("Redis running at %j", @getRedis(), {})

		@client = redis.createClient @getRedis().port, @getRedis().ip 
		@client.on "error", (err) => winston.error("Can't connect to redis: %j", err)
		@client.on "end", () => winston.info("Connection ended.")

		@server = require("bouncy") (req, res, bounce) => 
			winston.info("[request] %s", req.url)
			wid = require("url").parse(req.url, true)?.query?.wid

			if not wid?
				winston.error("Can't read wid from request: %j", req, {})
				@onError(res)

			@client.hgetall wid, (err, obj) =>
				if err
					winston.error("Error getting worker object: %j", err, {})
					@onError(res)
				else if not obj?
					winston.error("Invalid worker object: %j", obj, {})
					@onError(res)
				else
					@keepalive(wid)
					winston.info("Bouncing to %j", obj, {})
					bounce("#{obj.ip}:#{obj.port}")

	run: (port) ->
		port = port ? 8023
		winston.info("Proxy server running on %d", port)
		@server.listen(port)

	keepalive: (wid) ->
		winston.info("Keep alive %j", Date.now(), {})
		@client.hset wid, "lastActive", Date.now()

	server: null
	client: null

module.exports = proxy;
