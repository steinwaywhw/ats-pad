

angular.module("ats-pad").controller("MainController", function ($http, $scope, $location, $interval) {
	
	$scope.bar = {
    	row: 0,
    	col: 0,
    	has_sel: false
    };

    $scope.pg = {
    	id: "",
    	filenames: ["main.dats"],
    	files: ["implement main () = ()"]
    };

    $scope.active_file = function () {
    	if (!$location.search())
    		return 0;
    	if (!$location.search()['file'])
    		return 0;
    	return $location.search()['file'];
    }

    $scope.switch_file = function (index) {
    	$scope.editor.setValue($scope.pg.files[index]);
    	$location.search("file", index);
    }

    $scope.$location = $location;

	$scope.update_statusbar = function ($scope) {
		var c = $scope.editor.selection.lead;
        var r = $scope.editor.getSelectionRange();

        $scope.bar = {
        	row: c.row + 1,
        	col: c.column + 1,
        	has_sel: !$scope.editor.selection.isEmpty(),
        	sel: {
        		srow: r.start.row + 1,
        		scol: r.start.column + 1,
        		erow: r.end.row + 1,
        		ecol: r.end.row + 1
        	}
        };
	};

	$scope.run = function () {
		$http.post("api/" + $scope.pg.id + "/run", angular.toJson($scope.pg), function (data, status, headers, config) {
			console.log(dats);
		});
	};

	$scope.init_editor = function () {
		var editor = ace.edit("ats-pad-editor");
		editor.getSession().setUseWorker(false);
		editor.setTheme("ace/theme/idle_fingers");
		editor.getSession().setMode("ace/mode/javascript"); 
		editor.getSession().setUseSoftTabs(true);
		editor.setShowPrintMargin(false);

		$scope.editor = editor;

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

		editor.setValue($scope.pg.files[0]);
	};

	$scope.init = function () {
		if ($location.path() == "")
			$scope.uuid();
		else
			$scope.pg.id = $location.path().substr(1);

		$scope.init_editor();
	}

	$scope.uuid = function () {
		$http({method: 'GET', url: 'api/uuid'}).
		    success(function(data, status, headers, config) {
		    	$scope.pg.id = data;
		    }).
		    error(function(data, status, headers, config) {
		    	alert("error");
		    });
	};	

	$scope.newfile = function () {
		var name = "";
		if ($scope.input && $scope.input.filename) {
			$('#modal-new-file').modal('hide');
			name = $scope.input.filename;

			$interval(function () {
				$scope.input.filename = "";
			}, 1000, 1);

			$scope.pg.filenames.push(name);
			$scope.pg.files.push("");

			$scope.switch_file($scope.pg.files.length - 1);
		}
	}
});