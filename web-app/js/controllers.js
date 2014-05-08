//events:
//atspad-id-ready
//atspad




angular.module("ats-pad").controller("FileController", function ($rootScope, $scope, $log) {
   
    $scope.init_file = function () {
        $scope.env.editing = [];
        $scope.env.files.forEach(function (e, i) {
            $scope.env.editing[i] = false;
        });
    };

    $scope.is_active = function (index) {
        return $scope.env.active == index;
    };
    
    //TODO
    $scope.guess_mode = function (filename) {
        return "ace/mode/markdown";
    };
    
    $scope.switch_to = function (index) {
        $log.debug("Switch to " + index);
        
        var editor = $scope.env.editor;
        
        editor.setValue($scope.env.files[index]);
        $scope.env.active = index;
        
        var mode = $scope.guess_mode($scope.env.filenames[index]);
		editor.getSession().setMode(mode);
        
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
        
        var index = $scope.env.files.length - 1;
        $scope.env.editor.setValue($scope.env.files[index]);
        $scope.env.active = index;
    };
   
    $scope.init_file(); 
});


angular.module("ats-pad").controller("MainController", function ($rootScope, $http, $scope, $location, $interval, $log) {
	
    // environment object
    var env = {
        id: "",
        filenames: ["README.md"],
        files: ["# Hello World\n\nWelcome to ats-pad! You can use [Markdown](https://daringfireball.net/projects/markdown/) syntax to write README."],
        active: 0,
        events: ["atspad-id-ready"]
    };
    
    $scope.env = env;

    // // adapt env to a pad object
    // $scope.env2pad = function () {
    //     var env = $scope.env;
    //     var pad = {files: {}};
    //     pad.id = env.id;
    //     $.each(env.filenames, function (index, value) {
    //         pad.files[value] = env.files[index];
    //     });

    //     return pad;
    // };

    // // adapt pad object to env
    // $scope.pad2env = function (pad) {
    //     $scope.env.filenames = [];
    //     $scope.env.files = [];
    //     $scope.env.id = pad.id;
    //     $.each(pad.files, function (key, value) {
    //         $scope.env.filenames.push(key);
    //         $scope.env.files.push(value);
    //     });
    // };

    // $scope.refresh = function () {
    //     $log.debug("Refreshing files");
        
    //     var api = "api/pad/" + $scope.env.id + "/file";
    //     $http
    //     .get(api)
    //     .success(function (data, status) {
    //         $scope.pad2env(data);
    //     })
    //     .error(function (data, status) {
    //         alert(data);
    //     });
    // };

    // $scope.upload = function () {
    //     $log.debug("Uploading files");
        
    //     var api = "api/pad/" + $scope.env.id + "/file";
    //     $http
    //     .post(api, angular.toJson($scope.env2pad()))
    //     .success(function (data, status) {
    //         alert(data);
    //     })
    //     .error(function (data, status) {
    //         alert(data);
    //     });
    // };

	$scope.init = function () {
        $log.debug("Init main app");

        var path = window.location.pathname;
        
        if (path == "/" || path === "") {
            // UrlMapping: "/"
			$scope.create();
        } else {
            // UrlMapping: "/$id"
			$scope.show(path.substr(1));
        }

        // init editor
		//$scope.init_editor();
	};

    // $scope.show = function (id) {
    //     $log.debug("Loading " + id);

    //     var api = "api/pad/" + id;
    //     $http
    //     .get(api)
    //     .success(function (data, status) {
    //         $scope.pad2env(data);
    //         $rootScope.$emit("atspad-id-ready");
    //     })
    //     .error(function (data, status) {
    //         alert(data);
    //     });
    // };

	// $scope.create = function () {
 //        $log.debug("Creating new pad.");
        
 //        var api = "api/pad";
	// 	$http
	// 	.get(api)
	// 	.success(function(data, status) {
 //            // $scope.pad2env(data);
 //            // $scope.$emit("atspad-id-ready");
 //            // $scope.$broadcast("atspad-id-ready");

 //            window.location.replace(data.id);
 //        })
 //        .error(function(data, status) {
 //            alert(data);
 //        });
	// };	
        
    $scope.init();
});