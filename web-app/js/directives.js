angular.module("ats-pad").directive("appFileList", function (appContextService, appFileService) {

	var link = function (scope, element, attrs) {
		appFileService.init();

		scope.$watchCollection(
			function (scope) {
				return appContextService.getEnv("pad");
			}, 
			function (newv, oldv, scope) {
				scope.$apply(function () {
					scope.files = newv.files;
					scope.filenames = newv.filenames;
				});
			});
	};

    return {
    	restrict: "AE",
        templateUrl: "snippets/filelist.html",
        replace: false
    }
});


angular.module("ats-pad").directive("appReadme", function (appContextService, appFileService, appMarkdownService) {

	var findDefault = function (pad) {
		pad.filenames.forEach(function (v, i) {
			if (appFileService.isReadme(v)) {
				return i;
			}
		});
		return null;
	};

	var toDisplay = function (pad, active) {

		var index = null;

		// find index
		if (appFileService.isReadme(pad.filenames[active]))
			index = active;
		else 
			index = findDefault();

		// find content and title
		if (index)
			return {
				title: pad.filenames[index],
				content: appMarkdownService.toHtml(pad.files[index])
			};
		else
			return {
				title: "README",
				content: "Please describe your project :)"
			};
	};

	var link = function (scope, element, attrs) {

		scope.toggle = function () {
			element.find(".panel-body").toggleClass("collapse");
		}

		var pad = appContextService.getEnv("pad");
		var active = appFileService.active();

		scope.$watch(
			function () {
				var pad = appContextService.getEnv("pad");
				var active = appFileService.active();

				return toDisplay(pad, active);
			}, 
			function (newv, oldv) {
				scope.$apply(function () {
					scope.title = newv.title;
					scope.content = newv.content;
				});
		});

		scope.$digest();
	};

	return {
		scope: {},
		restrict: "AE",
		templateUrl: "snippets/readme.html",
		replace: false,
		link: link
	}
});

angular.module("ats-pad").directive("appFileToolbar", function () {
	return {
		restrict: "AE",
		templateUrl: "snippets/filetoolbar.html",
		replace: false
	}
});

angular.module("ats-pad").directive("appStatusBar", function (appEditorService) {

	var link = function (scope, element, attrs) {

		scope.$apply(function () {
			scope.bar = appEditorService.getCursorStatus();
		});

		var editor = appEditorService.getEditor();

		editor.getSession().selection.on("changeSelection", function () {
			scope.$apply(function () {
				scope.bar = appEditorService.getCursorStatus();
			});
		});

		editor.getSession().selection.on("changeCursor", function () {
			scope.$apply(function () {
				scope.bar = appEditorService.getCursorStatus();
			});
		});
	};

	return {
		scope: {},
		restrict: "AE",
		templateUrl: "snippets/statusbar.html",
		replace: false,
		link: link
	}
});

angular.module("ats-pad").directive("appTerminal", function (appTerminalService) {

	var link = function (scope, element, attrs) {
		var options = {};
		options.parent = element.get();
		if (attrs.cols)
			options.cols = attrs.cols;
		if (attrs.rows)
			options.rows = attrs.rows;

		appTerminalService.init(element.attr('id'), options);
	};

	return {
		link: link
	};
});

angular.module("ats-pad").directive("appEditor", function (appEditorService, appContextService, appFileService, $log) {

	var link = function (scope, element, attrs) {
		var id = element.attr("id");

		appEditorService.init(id);

		var editor = appEditorService.getEditor();
		var pad = appContextService.getEnv("pad");
		editor.setValue(pad.files[0]);

		// bind events
		$(document).ready(function () {
			var editor = appEditorService.getEditor()
			editor.clearSelection();
			editor.focus();
		});

		editor.getSession().on("change", function (e) {
			var pad = appContextService.getEnv("pad");
			var active = appFileService.active();
			pad.files[active] = editor.getValue();
			appContextService.setEnv("pad", pad);
		});

		scope.$watch(
			function () { 
				return appFileService.active(); 
			},
			function (newv, oldv) {
				var editor = appEditorService.getEditor();
				var pad = appContextService.getEnv("pad");
				var active = appFileService.active();
				var filename = pad.filenames[active];
				var mode = appFileService.guessMode(filename);
				var content = pad.files[active];

				editor.setValue(content);
				editor.getSession.setMode(mode);
				editor.clearSelection();
				editor.focus();
		});

		scope.$watch(
			function () {
				var pad = appContextService.getEnv("pad");
				var active = appFileService.active();
				return pad.files[active];
			},
			function (newv, oldv) {
				var editor = appEditorService.getEditor();
				editor.setValue(newv);
				editor.clearSelection();
				editor.focus();
		});
	};

	return {
		link: link
	}
});
