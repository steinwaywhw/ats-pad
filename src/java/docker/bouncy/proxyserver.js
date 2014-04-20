

var redis = require('redis');
var bouncy = require('bouncy');
var cookie = require('cookie');
var url = require('url');
var util = require('util');


var proxy = {};
var context = {};


//todo
context.redis = function () {
	if (!process.env.ATSPAD_REDIS_HOST) {
		console.log("Missing environment variable ATSPAD_REDIS_HOST");
		return null;
	}

	return {
		host: process.env.ATSPAD_REDIS_HOST,
		port: process.env.ATSPAD_REDIS_PORT || 6379
	}
}

context.app = function () {
	var client = context.client;
	var app = null;

	client.hgetall("server:atspad", function (err, obj) {
		if (!err) app = obj;
	});

	return app;
}


context.init = function () {
	console.log("Init proxy context.");

	var db = context.redis();
	var client = redis.createClient(db.port, db.host, {});
	context.client = client;

	client.on("ready", function () {
		var app = context.app();
		console.log(util.format("Appserver: %s:%s", app.host, app.port));
		console.log(util.format("Redis: %s:%s", db.host, db.port));
	});

	client.on("error", function () {
		console.log(util.format("Error - Can't connect to Redis on %s:%s", db.host, db.port));
	});
}

proxy.dest = function (req) {
	var path = url.parse(req.url).pathname;

	if (path.contains("/console")) {
		return {go: proxy.goworker};
	}
	else
		return {go: proxy.goapp};
	
}

proxy.goapp = function (req, res, bounce) {
	var app = proxy.context.app();

	if (!app) {
		console.log("Error - Can't find app server.");
		proxy.onerror(res);
	}

	bounce(app.host, app.port);
}

proxy.goworker = function (req, res, bounce) {

	// UrlMapping: /$id/console
	// find atspadid
	var atspadid = path.substring(1) || "";
	if (atspadid)
		atspadid = atspadid.replace(/\/console.*/gi, "") || "";

	// error
	if (!atspadid) {
		console.log("Error - Can't find atspadid from url.");
		proxy.onerror(res);
	}

	// find sessionid
	var reqcookie = cookie.parse(req.headers.cookie);
	var sessionid = reqcookie.JSESSIONID || cookie.jsessionid || "";

	// error
	if (!sessionid) {
		console.log("Error - Can't find jsessionid from cookie.");
		proxy.onerror(res);
	}

	// Worker ID: worker:sid:aid
	// find worker id
	var wid = util.format("worker:%s:%s", sessionid, atspadid);

	// find docker
	var docker = null;
	var client = proxy.client;
	client.hgetall(wid, function (err, obj) {
		if (err) {
			console.log(err);
		} else {
			docker = obj;
		}
	});

	// if (Object.keys(docker).length === 0)
	// 	docker = null;
	
	// error
	if (!docker) {
		console.log(util.format("Error - Can't find docker %s", wid));
		proxy.onerror(res);
	}

	proxy.keepalive(wid);
	bounce(docker.ip, docker.port);
}


proxy.onerror = function (res) {
	res.statusCode = 500;
	res.end('Proxy error.');
};

// proxy.check = function (req, rec) {
// 	var reqcookie = cookie.parse(req.headers.cookie);
// 	var reqsid = proxy.getsid(reqcookie);
// 	var reqaid = cookie.aid;
// 	var urlaid = req.url.substring(1);

// 	if (reqsid != rec.sid)
// 		return false;
// 	if (reqaid != urlaid)
// 		return false;

// 	return true;
// };

proxy.keepalive = function (key) {
	proxy.client.hset(key, "lastactive", new Date());
};



proxy.init = function () {
	console.log("Init proxy server");

	context.init();
	proxy.context = context;
	proxy.client = context.client;

	proxy.server = bouncy(function (req, res, bounce) {
		proxy.dest(req).go(req, res, bounce);
	});
};

proxy.run = function (port) {
	proxy.server.listen(port || 8023);
};

module.exports = proxy;


