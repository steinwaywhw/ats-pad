angular.module("ats-pad").directive("appFileList", function ($log, appContextService, appFileService) {

    return {
    	restrict: "AE",
        templateUrl: "snippets/filelist.html",
        replace: false,
       // link: link
    }
});

angular.module("ats-pad").directive("appLoadingScreen", function ($log, appContextService) {



	return {
		restrict: "AE",
		templateUrl: "snippets/loading.html",
		replace: false,
		link: function (scope, element, attrs) {
			scope.service = appContextService;
		}
	};
})


angular.module("ats-pad").directive("appReadme", function ($timeout, $log, appContextService, appFileService, appMarkdownService, appEditorService) {

	var findDefault = function (pad) {
		var index = null;
		pad.filenames.forEach(function (v, i) {
			if (appFileService.isReadme(pad, i)) {
				index = i;
			}
		});
		return index;
	};

	var toDisplay = function (pad, active) {

		var index = null;

		// find index
		if (appFileService.isReadme(pad, active))
			index = active;
		else 
			index = findDefault(pad);

		// find content and title
		if (index !== null)
			return {
				title: pad.filenames[index],
				content: appMarkdownService.toHtml(pad.files[index])
			};
		else {
			return {
				title: "README",
				content: "Please describe your project :)"
			};
		}
	};

	var link = function (scope, element, attrs) {

		scope.toggle = function () {
			element.find(".panel-body").toggleClass("collapse");
		}

		
		var pad = scope.pad;
		var active = appFileService.active();

		scope.$watch(
			function (scope) {
				if (!appContextService.isReady())
					return false;
				else {
					var pad = scope.pad;
					var active = appFileService.active();

					return toDisplay(pad, active);
				}
			}, 
			function (newv, oldv, scope) {
				if (!appContextService.isReady())
					return;
				else {
					scope.title = newv.title;
					scope.content = newv.content;
				}		
			},
			true
		);

		// var editor = appEditorService.getEditor();
		// editor.getSession().on("change", function (e) {
		// 	$timeout(function () {
		// 		var pad = scope.pad;
		// 		var active = appFileService.active();
		// 		var obj = toDisplay(pad, active);
		// 		scope.title = obj.title;
		// 		scope.content = obj.content;
		// 	});
		// });
	};

	return {
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

angular.module("ats-pad").directive("appStatusBar", function (appEditorService, $timeout) {

	var link = function (scope, element, attrs) {

		scope.bar = appEditorService.getCursorStatus();

		var editor = appEditorService.getEditor();

		editor.getSession().selection.on("changeSelection", function () {
			$timeout(function () {
				scope.bar = appEditorService.getCursorStatus();
			});
		});

		editor.getSession().selection.on("changeCursor", function () {
			$timeout(function () {
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

angular.module("ats-pad").directive("appTerminal", function ($log, appTerminalService, appContextService) {

	var link = function (scope, element, attrs) {
		var options = {};
		options.parent = element.get();
		if (attrs.cols)
			options.cols = attrs.cols;
		if (attrs.rows)
			options.rows = attrs.rows;

		scope.$watch(
			function () {
				return appContextService.isReady();
			},
			function (newv, oldv) {
				$log.debug("In Term: " + newv + oldv);
				if (newv)
					appTerminalService.init(element.attr('id'), options);
			},
			true
		);
		
	};

	return {
		link: link
	};
});

angular.module("ats-pad").directive("appEditor", function (appEditorService, appContextService, appFileService, $log, $timeout) {

	var link = function (scope, element, attrs) {
		var id = element.attr("id");

		appEditorService.init(id);

		var editor = appEditorService.getEditor();
				

		// bind events
		$(document).ready(function () {
			var editor = appEditorService.getEditor();
			editor.clearSelection();
			editor.focus();
		});

		editor.getSession().on("change", function (e) {
			$timeout(function () {
				if (!appContextService.isReady())
					return;
				else {
					var pad = scope.pad;
					var active = appFileService.active();
					pad.files[active] = editor.getValue();
				}
			});
		});

		scope.$watch(
			function () { 
				return appFileService.active(); 
			},
			function (newv, oldv) {
				if (!appContextService.isReady())
					return;
				else {
					var editor = appEditorService.getEditor();
					var pad = scope.pad;
					var active = appFileService.active();
					var filename = pad.filenames[active];
					var mode = appFileService.guessMode(filename);
					var content = pad.files[active];

					editor.setValue(content);
					editor.getSession().setMode(mode);
					editor.clearSelection();
					editor.focus();
				}
			}
		);

		scope.$watch(
			function () {
				if (!appContextService.isReady())
					return false;
				else {
					var pad = scope.pad;
					var active = appFileService.active();
					return pad.files[active];
				}
			},
			function (newv, oldv) {
				if (!appContextService.isReady())
					return;
				else {
					var editor = appEditorService.getEditor();
					var cursor = editor.getSelection().getCursor();
					editor.setValue(newv);
					editor.clearSelection();
					editor.moveCursorToPosition(cursor);
					//editor.getSelection().setCursor(cursor);
					//editor.clearSelection();
					//editor.selection.lead = cursor;
				}
			},
			true
		);

		scope.$watch(
			function () {
				if (!appContextService.isReady())
					return false;
				else {
					var pad = scope.pad;
					var active = appFileService.active();
					return appFileService.guessMode(pad.filenames[active]);
				}
			},
			function (newv, oldv) {
				if (!appContextService.isReady())
					return;
				else {
					var editor = appEditorService.getEditor();
					editor.getSession().setMode(newv);
				}
			},
			true
		);
	};

	return {
		link: link
	}
});


// angular.module("ats-pad").directive("appTestEmbed", function () {
// 	return {
// 		restrict: "AE",
// 		templateUrl: "embed.html",
// 		replace: false,
// 	}
// });