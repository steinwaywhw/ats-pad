angular.module("ats-pad").factory("appContextService", function ($rootScope, $log) {
	var env = {};
	var id = null;
	var ready = false;

	var mixin = {};

	mixin.getId = function () {
		return id;
	};

	mixin.setId = function (data) {
		id = data;
	};

	mixin.getEnv = function (key) {
		return env[key];
	};

	mixin.setEnv = function (key, value) {
		env[key] = value;
	};

	mixin.isReady = function () {
		return ready;
	};

	mixin.ready = function () {
		ready = true;
	};

	mixin.debug = function () {
		$log.debug("Debug info for app context: " + id);
		$log.debug(env);
	};

	return mixin;
});

angular.module("ats-pad").factory("appNotificationService", function ($rootScope, $log) {
	var mixin = {};
	var errorQueue = [];
	var infoQueue = [];

	var ERROR = "E";
	var INFO = "I";

	mixin.error = function (message) {
		errorQueue.push(message);
	};

	mixin.info = function (message) {
		infoQueue.push(message);
	};

	mixin.hasNext = function (type) {
		if (type === ERROR)
			return errorQueue.length === 0;
		if (type === INFO)
			return infoQueue.length === 0;
		else 
			return false;
	};

	mixin.next = function (type) {
		if (type === ERROR)
			return errorQueue.shift();
		if (type === INFO)
			return infoQueue.shift();
		else 
			return "";
	};

	return mixin;
});

angular.module("ats-pad").factory("appPadService", function ($http, $log, $rootScope, appNotificationService, appContextService, appFileService) {
	var mixin = {};
	var API_PREFIX = "api/pad";

	var toserver = function (pad) {
		var files = {};

		$.each(pad.filenames, function (index, value) {
		    files[value] = pad.files[index];
		});

		return {
			id: pad.id,
			files: files
		};
	};

	var fromserver = function (pad) {
		var filenames = [];
		var files = [];
		
		$.each(pad.files, function (key, value) {
		    filenames.push(key);
		    files.push(value);
		});

		return {
			id: pad.id,
			files: files,
			filenames: filenames
		};
	};

	mixin.create = function () {
		$log.debug("Creating new pad.");

		$http
		.get(API_PREFIX)
		.success(function (id, status) {
			$log.debug("Success: " + id);
			return id;
		})
		.error(function (data, status) {
			$log.debug("Error: " + data);
			appNotificationService.error("Failed to create new pad: " + data);
		});
	};

	mixin.show = function (id, callback) {
		$log.debug("Loading " + id);

		$http
		.get(API_PREFIX + "/" + id)
		.success(function (pad, status) {
			$log.debug("Success: " + id);

			callback(fromserver(pad));
		})
		.error(function (data, status) {
			$log.debug("Error: " + data);
			appNotificationService.error("Failed to load pad: " + data);
		});
	};

	mixin.syncToServer = function (pad) {
		$log.debug("Uploading files.");

		var data = angular.toJson(toserver(pad));
		$http
		.post(API_PREFIX + "/" + pad.id + "/file", data)
		.success(function (data, status) {
			$log.debug("Success");
			appNotificationService.info("Changes have been saved.");
		})
		.error(function (data, status) {
			$log.debug("Error: " + data);
			appNotificationService.error("Failed to save changes: " + data);
		});
	};

	mixin.syncToClient = function (callback) {
		$log.debug("Refreshing files.");

		$http
		.get(API_PREFIX + "/" + appContextService.getId() + "/file")
		.success(function (pad, status) {
			$log.debug("Success: " + appContextService.getId());
			appNotificationService.info("Files have been refreshed.");
			callback(fromserver(pad));

		})
		.error(function (data, status) {
			$log.debug("Error: " + data);
			appNotificationService.error("Failed to load pad: " + data);
		});
	};

	mixin.fork = function (callback) {
		$log.debug("Forking files.");

		$http
		.get(API_PREFIX + "/" + appContextService.getId() + "/fork")
		.success(function (id, status) {
			$log.debug("Success: " + id);
			appNotificationService.info("Forked.");
			callback(id);

		})
		.error(function (data, status) {
			$log.debug("Error: " + data);
			appNotificationService.error("Failed to fork pad: " + data);
		});
	};

	mixin.delete = function (callback) {
		$log.debug("Deleting pad.");

		$http
		.delete(API_PREFIX + "/" + appContextService.getId())
		.success(function (data, status) {
			$log.debug("Success: " + data);
			appNotificationService.info("Files have been refreshed.");
			callback(data);

		})
		.error(function (data, status) {
			$log.debug("Error: " + data);
			appNotificationService.error("Failed to load pad: " + data);
		});
	};

	mixin.validate = function (pad) {
		var result = true;

		if (!pad || !pad.files || !pad.filenames || !pad.id) {
			result = false;
		} else {
			pad.filenames.forEach(function (e) {
				if (e === null || e === "") {
					result = false;
				}
			});

			pad.files.forEach(function (e) {
				if (e === null) {
					result = false;
				}
			});
		}

		return result;
	};

	return mixin;
});

angular.module("ats-pad").factory("appEditorService", function ($rootScope, appContextService, $log) {

	var id = null;
	var editor = null;
	var mixin = {};

	var cs = appContextService;

	mixin.init = function (selector) {
		$log.debug("Init editor.");
		id = selector;

		editor = ace.edit(id); // ace is external variable
		var session = editor.getSession();
		session.setUseWorker(false);
		editor.setTheme("ace/theme/idle_fingers");
		session.setUseSoftTabs(true);
		editor.setShowPrintMargin(false);
        editor.setOption("vScrollBarAlwaysVisible", false);
        session.setUseWrapMode(true);
        session.setWrapLimitRange(null, null);

        this.setMode("markdown"); // TODO?
	};

	mixin.getEditor = function () {
		return editor;
	};

	mixin.getCursorStatus = function () {
		var c = editor.getSelection().getSelectionLead();
        var r = editor.getSelectionRange();

        return {
        	row: c.row + 1,
        	col: c.column + 1,
        	hasSel: editor.selection.isEmpty(),
        	sel: {
        		srow: r.start.row + 1,
        		scol: r.start.column + 1,
        		erow: r.end.row + 1,
        		ecol: r.end.col + 1
        	}
        };
	};

	mixin.setMode = function (mode) {
		editor.getSession().setMode("ace/mode/" + mode);
	};

	return mixin;
});

angular.module("ats-pad").factory("appMarkdownService", function ($log) {
	var mixin = {};
	var marker = markdown; // markdown is external 


	mixin.toHtml = function (md) {
		return marker.toHTML(md);
	};

	return mixin;
});

angular.module("ats-pad").factory("appFileService", function ($rootScope, $log, appContextService) {
	var active = 0;
	var editing = [];

	var cs = appContextService;

	var mixin = {};

	mixin.init = function (pad) {
		$log.debug("Init file ui service.");
		editing.length = 0;

		pad.files.forEach(function (e, i) {
			editing.push(false);
		});

		active = 0;
	};

	mixin.isActive = function (index) {
		return index === active;
	};

	mixin.isEditing = function (index) {
		return editing[index];
	};

	mixin.active = function () {
		return active;
	};

	mixin.select = function (index) {
		active = index;
	};

	mixin.edit = function (index) {
		editing[index] = true;
	};

	mixin.done = function (pad, index) {
		if (!this.validate(pad.filenames[index]))
			return; 

		editing[index] = false;
		active = index;
	};

	mixin.validate = function (filename) {
		return filename && /\w+/.test(filename) && filename.length < 64 && filename.length >= 1;
	};

	mixin.guessMode = function (filename) {
		// TODO
		var modes = {
			'ace/mode/markdown': [".*\\.md$", "readme.*"],
			"ace/mode/ats": [".*\\.[ds]ats$"],
			"ace/mode/c_cpp": [".*\\.[ch]$", ".*\\.[ch]ats$"],
			"ace/mode/java": [".*\\.java$"]
		};

		var mode = "ace/mode/text";

       	$.each(modes, function (key, value) {
       		
       		value.forEach(function (regexp) {
       			if (new RegExp(regexp, "i").test(filename))
       				mode = key;
       		});
       	});

        return mode;
	};

	mixin.create = function (pad) {
		pad.files.push("");
		pad.filenames.push("");
		editing.push(true);
		active = pad.files.length - 1;

		return pad;
	};

	mixin.remove = function (pad, index) {
		if (this.isReadme(pad, index))
			return; 

		pad.filenames.splice(index, 1);
        pad.files.splice(index, 1);
        editing.splice(index, 1);     

        if (active === pad.files.length)
        	active = active - 1;   

        return pad;
	};

	mixin.isReadme = function (pad, index) {
		
		if (/readme.*/i.test(pad.filenames[index]))
			return true;
		else
			return false;
	};

	return mixin;

});

angular.module("ats-pad").factory("appTerminalService", function ($timeout, $http, $log, appNotificationService, appContextService) {
	var id = null;
	var termclient = client; // client is external

	var options = {
		path: "console",
		remote: null,
		parent: null,
		cols: 140,
		rows: 19
	};

	var API_PREFIX = "api/pad";

	var mixin = {};

	mixin.init = function (selector, opts) {
		$log.debug("Init term.");

		id = selector;
		options.parent = document.getElementById(id);
		options.cols = opts.cols || options.cols;
		options.rows = opts.rows || options.rows;

		// delay 10 seconds for the worker to boot up
		$timeout(function () {
			$http
			.get(API_PREFIX + "/" + appContextService.getId() + "/worker")
			.success(function (remote, status) {
				$log.debug("Success: " + remote);
				options.remote = remote;

				termclient.run(options);
			})
			.error(function (data, status) {
				$log.debug("Error: " + data);
				appNotificationService.error("Failed to initialize terminal: " + data);
			});
		}, 10 * 1000);
	};

	mixin.cmd = function (cmd) {
		termclient.term.emit("data", cmd + "\n");
	};

	mixin.message = function (msg) {
		termclient.term.write("\n\r" + msg);
		this.cmd("\n");
	};

	return mixin;
});