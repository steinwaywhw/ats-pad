
angular.module("ats-pad").controller("FilelistController", function ($scope) {
   
    $scope.env.editing = [];
    $scope.env.files.forEach(function (e, i) {
        $scope.env.editing[i] = false;
    });

    
    $scope.is_active = function (index) {
        return $scope.env.active == index;
    };
    
    $scope.switch_to = function (index) {
        $scope.env.editor.setValue($scope.env.files[index]);
    	$scope.env.active = index;
        
        $scope.env.editor.clearSelection();
        $scope.env.editor.focus();
    };
    
    $scope.file_control_class = function (index) {
        if ($scope.is_active (index))
            return "btn btn-xs control btn-primary pull-right"
        else
            return "btn btn-xs control btn-default pull-right"
    };
    
    $scope.delete_file = function (index) {    
        $scope.env.filenames.splice(index, 1);
        $scope.env.files.splice(index, 1);
        $scope.env.editing.splice(index, 1);
    };
    
    $scope.create_file = function () {
        $scope.env.filenames.push("");
        $scope.env.files.push("");
        $scope.env.editing.push(true);
        
        $scope.env.editor.setValue($scope.env.files[index]);
    	$scope.env.active = index;
    };
    
});

angular.module("ats-pad").controller("MarkdownController", function ($scope, $interval) {
    $scope.env.marker = markdown;
    
    $scope.env.editor.getSession().on('change', function(e) {
        $interval(function () {
            var re = /readme\.md/i;
            if (re.test($scope.env.filenames[$scope.env.active]))
                $("#ats-pad-markdown").html($scope.env.marker.toHTML($scope.env.editor.getValue()));
        }, 1, 1);
    });
    
    $scope.toggle_readme = function () {
        $('#ats-pad-readme > .panel-body').toggleClass('collapse');
    };
    
    var readme = $scope.env.filenames.indexOf('README.md');
    if (readme >= 0) {
        $("#ats-pad-markdown").html($scope.env.marker.toHTML($scope.env.files[readme]));
        $('#ats-pad-readme > .panel-body').toggleClass('collapse', false);
    } else {
        $('#ats-pad-readme > .panel-body').toggleClass('collapse', true);
    }
});

angular.module("ats-pad").controller("StatusBarController", function ($scope, $interval) {
    $scope.env.bar = {row: 0, col: 0, has_sel: false};
    
    $scope.update_statusbar = function ($scope) {

		var c = $scope.env.editor.selection.lead;
        var r = $scope.env.editor.getSelectionRange();

        $scope.env.bar = {
        	row: c.row + 1,
        	col: c.column + 1,
        	has_sel: !$scope.env.editor.selection.isEmpty(),
        	sel: {
        		srow: r.start.row + 1,
        		scol: r.start.column + 1,
        		erow: r.end.row + 1,
        		ecol: r.end.row + 1
        	}
        };
	};
    
    $scope.init_statusbar = function () {
        
        var editor = $scope.env.editor;
        
        // has to use interval to bind it
        editor.getSession().selection.on("changeCursor", function () {
            $interval(function () {
                $scope.update_statusbar ($scope);
            }, 1, 1);

        });
        
        editor.getSession().selection.on("changeSelection", function () {
            $interval(function () {
                $scope.update_statusbar ($scope);
            }, 1, 1);
        });
        
        editor.focus();
    };
    
    $scope.init_statusbar();
    
});

angular.module("ats-pad").controller("MainController", function ($http, $scope, $location, $interval, $log) {
	
    // environment object
    var env = {
    	id: "",
    	filenames: ["README.md", "main.dats", "hello.sats"],
    	files: ["# Hello World\n\nWelcome to ats-pad! You can use [Markdown](https://daringfireball.net/projects/markdown/) syntax to write README.", "implement main () = ()", "hello"],
        active: 0,
        editor: {}
    };
    
    $scope.env = env;

    // adapt env to a pad object
    $scope.env2pad = function () {
        var env = $scope.env;
        var pad = {files: {}};
        pad.id = env.id;
        $.each(env.filenames, function (index, value) {
            pad.files[value] = env.files[i];
        });

        return pad;
    };

    // adapt pad object to env
    $scope.pad2env = function (pad) {
        $scope.env.filenames = [];
        $scope.env.files = [];
        $.each(pad, function (key, value) {
            $scope.env.filenames.push(key);
            $scope.env.files.push(value);
        });
    };
    

  

// 	$scope.run = function () {
// 		$http.post("api/" + $scope.env.id + "/run", angular.toJson($scope.env))
// 			.success(function (data, status, headers, config) {
// //				$scope.env.stdout = data.map(function (e) {
// //					return $outputParser.decorate(e)
// //				})
// 			});
// 	};

    // init editor
	$scope.init_editor = function () {
		var editor = ace.edit("ats-pad-editor");
		editor.getSession().setUseWorker(false);
		editor.setTheme("ace/theme/idle_fingers");
		editor.getSession().setMode("ace/mode/markdown"); 
		editor.getSession().setUseSoftTabs(true);
		editor.setShowPrintMargin(false);
        editor.setOption("vScrollBarAlwaysVisible", false);
        editor.getSession().setUseWrapMode(true);
        editor.getSession().setWrapLimitRange(null, null);
        //renderer.setPrintMarginColumn(80);

		$scope.env.editor = editor;

        // bind editor data to env
		editor.getSession().on('change', function(e) {
			$interval(function () {
				$scope.env.files[$scope.env.active] = editor.getValue();
                $scope.upload();
			}, 1, 1);
		});

        // init to the first file
		editor.setValue($scope.env.files[0]);
        
        // clear selection
        $(document).ready(function () {
            $interval(function () {
                editor.clearSelection();
                editor.focus();
            }, 1, 1);
        });
	};

    $scope.refresh = function () {
        $http.get(
            'api/pad/' + $scope.env.id + '/file'
        ).success(function (data, status, headers, config) {
            $scope.pad2env(data);
        }).error(function (data, status, headers, config) {
            alert(data);
        });
    }

    $scope.upload = function () {
        $http.post(
            'api/pad/' + $scope.env.id + '/file',
            angular.toJson($scope.env2pad())
        }).success(function (data, status, headers, config) {
            alert(data);
        }).error(function (data, status, headers, config) {
            alert(data);
        });
    }

	$scope.init = function () {
		if ($location.path() == "/") {
            // UrlMapping: "/"
			$scope.create();
        } else {
            // UrlMapping: "/$id"
			$scope.show($location.path().substr(1));
        }

        // init editor
		$scope.init_editor();
	}

    $scope.show = function (id) {
        $log.debug("Loading " + id);

        $http({
            method: 'GET',
            url: 'api/pad/' + id
        }).success(function (data, status, headers, config) {
            $scope.pad2env(data);
        }).error(function (data, status, headers, config) {
            alert(data);
        });
    }

	$scope.create = function () {
        $log.debug("Creating new pad.");

		$http({
            method: 'GET', 
            url: 'api/pad'
        }).success(function(data, status, headers, config) {
	    	$scope.pad2env(data);
	    }).error(function(data, status, headers, config) {
	    	alert(data);
	    });
	};	

});