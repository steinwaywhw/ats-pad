var proxy = require("./proxy.js");
var port = process.env.ATSPAD_PROXY_PORT;

proxy.init();
proxy.run(port);