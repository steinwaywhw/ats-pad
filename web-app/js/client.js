

var client = {};

client.run = function (options) {

	options = options || {};


	var socket = io.connect(options.remote || "http://localhost:8080");
	socket.on('connect', function() {
		var term = new Terminal({
			cols: options.col || 180,
			rows: options.row || 30,
			useStyle: true,
			screenKeys: true
		});

		term.on('data', function(data) {
			socket.emit('data', data);
		});

		socket.on('data', function(data) {
			term.write(data);
		});

		term.open(options.parent || document.body);
		term.write('WELCOME!\r\n');

		socket.on('disconnect', function() {
			term.destroy();
		});

		// for displaying the first command line
		socket.emit('data', '\n');
	});
};