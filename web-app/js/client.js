

var client = {};

client.default = function (options) {
    'use strict';
    
    options = options || {};
    options.path = options.path || "console"
    options.remote = options.remote || "http://localhost:8080";
    options.reconnection_delay = options.reconnection_delay || 500;
    options.max_reconnection_attempts = options.max_reconnection_attempts || 20;
    options.col = options.col || 180;
    options.row = options.row || 30;
    options.parent = options.parent || document.body;
    options.connect_timeout = options.connect_timeout || 10000;
    //options.focus = options.focus || false;
    
    return options;
};



client.run = function (options) {
    'use strict';
    
	options = client.default(options);

	var term = new Terminal({
		cols: options.col,
		rows: options.row,
		useStyle: true,
		screenKeys: true,
	});

	term.open(options.parent);

    var socket = io.connect(options.remote, {
		'resource': options.path,
        'connect timeout': options.connect_timeout,
        'reconnection delay': options.reconnection_delay,
        'max reconnection attempts': options.max_reconnection_attempts 
    });
    
    // data
    term.on('data', function(data) {
		socket.emit('data', data);
	});

	socket.on('data', function(data) {
		term.write(data);
	});
    
    // Connecting
    socket.on('connecting', function () {
        term.write('Connecting to ' + options.remote + '\r\n');
    });
    
    socket.on('reconnecting', function () {
        term.write('Reconnecting ...\r\n');
    });
    
    // Fail
    socket.on('disconnect', function() {
        term.write("\r\nDisconnected.\r\n");
    });
    
    socket.on('error', function (err) {
        term.write('Connection Failed.\r\n');
        term.write('Refresh the page to retry.\r\n');
    });
    
    socket.on('reconnect_failed', function () {
	    term.write('Connection Failed.\r\n');
        term.write('Refresh the page to retry.\r\n');
    });
    
	socket.on('connect_failed', function(){
	    term.write('Connection Failed.\r\n');
        term.write('Refresh the page to retry.\r\n');
	});
    
    
    // Connected
//    socket.on('reconnect', function () {
//        
//        // for displaying the first command line
//		socket.emit('data', '\r\n');
//    });
    
    // work around
    var firsttime = true;
	socket.on('connect', function() {
		// for displaying the first command line
        if (firsttime) {
            socket.emit('data', '\r');
            firsttime = false;
        }
	});
};