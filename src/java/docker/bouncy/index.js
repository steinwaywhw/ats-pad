var proxy = require("./proxyserver.js");

proxy.init();

var port = process.ENV.ATSPAD_PROXY_PORT || 80;
proxy.run(port);