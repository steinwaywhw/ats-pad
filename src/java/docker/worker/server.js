

var server = {}

var http = require('http');
var express = require('express');
var io = require('socket.io');
var pty = require('pty.js');
var terminal = require('term.js');

var term;
var buff = [];

server.run = function(options) {

	// create shell process
	term = pty.fork(
		//process.env.SHELL || 'sh', 
		'bash',
		['--rcfile', '/root/.bashrc'], 
		{
			name: require('fs').existsSync('/usr/share/terminfo/x/xterm-256color')
				? 'xterm-256color'
				: 'xterm',
			cols: 140,
			rows: 19,
			//cwd: process.env.HOME
			cwd: '/root/atspad'
		}
	);

	// store term's output into buffer or emit through socket
	term.on('data', function(data) {
		return io.sockets.clients('clients').length == 0 ? buff.push(data) : io.sockets.in('clients').emit('data', data);
	});

	console.log('Created shell with pty master/slave pair (master: %d, pid: %d)', term.fd, term.pid);

	var app = express();
	var server = http.createServer(app);

	// let term.js handle req/res
	app.use(express.static(__dirname));
	app.use(terminal.middleware());

	// let server listen on the port
	options = options || {};
	server.listen(options.port || 8080);

	// let socket.io handle sockets
	io = io.listen(server, {log: true, resource: "/console"});

	io.sockets.on('connection', function(socket) {

		// join room
		socket.join('clients');

		// handle incoming data (client -> server)
		socket.on('data', function(data) {
			term.write(data);
		});

		// handle connection lost
		socket.on('disconnect', function() {
			socket.leave('clients')
		});

		// send buffer data to client
		while (buff.length) {
			io.sockets.in('clients').emit('data', buff.shift());
			//socket.emit('data', );
		};
	});
};


//server.run({port: 8080});

// export server object
module.exports = server;
