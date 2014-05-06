var redis = require('redis');
var bouncy = require('bouncy');
var url = require('url');
var util = require('util');

var proxy = {};
var context = {};

// store the redis connection info
context.redis = {
	ip: process.env.ATSPAD_REDIS_IP,
	port: process.env.ATSPAD_REDIS_PORT || 6379
};

// store the app server connection info 
context.app = {};

// init proxy context
context.init = function () {
	console.log("Init proxy context.");

    // get redis address
	var db = context.redis;
	
	// create redis client
	var client = redis.createClient(db.port, db.ip, {});
	context.client = client;

    // when connected
	client.on("ready", function () {
		
		// get app server address
		var client = context.client;
		client.hgetall("server:app", function (err, obj) {
            if (err)
                console.log(util.format("Error getting appserver: %s", err));
            else {
                context.app = obj;
                console.log(util.format("Appserver: %s:%s", obj.ip, obj.port));
            }
		});
		
		console.log(util.format("Redis: %s:%s", db.ip, db.port));
	});

    // when failed
	client.on("error", function () {
		console.log(util.format("Error - Can't connect to Redis on %s:%s", db.ip, db.port));
	});
};

// compute the destinatino from url
proxy.dest = function (req) {
	//console.dir(req);

	var path = url.parse(req.url).pathname;
	//console.log(req.url);
//	console.dir(url.parse(req.url));

	if (path.indexOf("/console") >= 0) 
		return {go: proxy.goworker};
	else
		return {go: proxy.goapp};
};

// bounce to app
proxy.goapp = function (req, res, bounce) {
	console.log("goapp");
	var app = proxy.context.app;

	if (!app) {
		console.log("Error - Can't find app server.");
		proxy.onerror(res);
	}

	var target = app.ip + ":" + app.port;
	console.log(target);
    bounce(target);				
};

// bounce to docker
proxy.goworker = function (req, res, bounce) {
	console.log("goworker");
	// UrlMapping: /console/?wid=$wid
    var wid = url.parse(req.url, true).query.wid;
    if (!wid) {
        console.log(util.format("Can't read wid from url: %s", req.url));
        proxy.onerror(res);
    }

	// find docker
	var client = proxy.client;
	client.hgetall(wid, function (err, obj) {
		if (err) {
			console.log(err);
			proxy.onerror(res);
		} else {
			var docker = obj;
			if (!docker) {
                console.log(util.format("Error - Can't find docker %s", wid));
                proxy.onerror(res);
            }

            proxy.keepalive(wid);

            var target = docker.ip + ":" + docker.port;
            console.log(target);
            bounce(target);
		}
	});
};

proxy.onerror = function (res) {
	res.statusCode = 500;
	res.end('Proxy error.');
};


proxy.keepalive = function (key) {
	proxy.client.hset(key, "lastActive", Date.now());
};



proxy.init = function () {
	console.log("Init proxy server");

	context.init();
	proxy.context = context;
	proxy.client = context.client;

	proxy.server = bouncy(function (req, res, bounce) {
		console.dir(req);
		proxy.dest(req).go(req, res, bounce);
		//bounce(8080);
	});
};

proxy.run = function (port) {
	proxy.server.listen(port || 8023);
	console.log("Proxy server is running on " + port);
};

module.exports = proxy;