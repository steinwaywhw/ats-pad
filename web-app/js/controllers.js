angular.module("ats-pad").controller("MainController", function ($scope, $location, $interval, $log, appContextService, appFileService, appPadService) {
	
    var binding = function () {
        $scope.$watch(
            "pad", 
            function (newv, oldv, scope) {
                if (!appPadService.validate(newv)) {
                    $log.debug("Failed to upload");
                } else {
                    appPadService.upload(newv);
                }
            },
            true
        );
    };

	$scope.init = function () {
        $log.debug("Init main app");

        var path = window.location.pathname;
        
        if (path === "/" || path === "") {
            // UrlMapping: "/"
			appPadService.create();
        } else {
            // UrlMapping: "/$id"
            var id = path.substr(1);
			appPadService.show(id, function (pad) {
                $scope.id = pad.id;
                $scope.pad = pad;

                // TODO
                appFileService.init(pad);

                appContextService.setId(pad.id);
                appContextService.ready();

                binding();
            });
        }
	};

   
       
    $scope.init();
    
});

angular.module("ats-pad").controller("FileController", function ($interval, $scope, $log, appFileService, appContextService, appPadService) {
    $scope.service = appFileService;

    $scope.refresh = function () {
        if (!appContextService.isReady())
            return;
        else {
            appPadService.refresh(function (pad) {
                // To avoid different pad in different scope
                // we only modify attributes of an object
                $scope.pad.filenames = pad.filenames;
                $scope.pad.files = pad.files;

                // TODO
                appFileService.init(pad);
            });
        }
    };

    // refresh every 10 second
    //$interval($scope.refresh, 10000);
});

angular.module("ats-pad").controller("SidebarController", function ($scope, $log, appFileService, appTerminalService, appPadService) {
    $scope.terminalService = appTerminalService;
    $scope.padService = appPadService;

    var getAtsFiles = function () {
        var files = [];
        $scope.pad.filenames.forEach(function (e) {
            if (/.*dats/i.test(e))
                files.push(e);
        });

        var filename = files.join(" ");
        return filename;
    };

    var getCurrentFileForTC = function () {
        var filename = $scope.pad.filenames[appFileService.active()];
        if (/.*dats/i.test(filename))
            return "-d " + filename;
        else if (/.*sats/i.test(filename))
            return "-s " + filename;
        else 
            return null;
    };

    $scope.run = function () {
        if (getAtsFiles().length === 0)
            appTerminalService.message("No file to run.");
        else {
            appTerminalService.cmd("patscc -o main " + getAtsFiles());
            appTerminalService.cmd("./main");
        }
    };

    $scope.typecheck = function () {
        if (getCurrentFileForTC() === null)
            appTerminalService.message("Can't type check current file: " + $scope.pad.filenames[appFileService.active()]);
        else {
            appTerminalService.cmd("patsopt -tc " + getCurrentFileForTC());
        }
    };

    $scope.newpad = function () {
        window.location.href = "/";
    };

    $scope.forkpad = function () {
        appPadService.fork(function (id) {
            window.location.href = "/" + id;
        });
    };

    $scope.deletepad = function () {
        appPadService.delete(function (data) {
            window.location.href = "/";
        });
    };
});