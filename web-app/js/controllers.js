angular.module("ats-pad").controller("MainController", function ($scope, $location, $interval, $log, appContextService, appFileService, appPadService) {
	
	$scope.init = function () {
        $log.debug("Init main app");

        var path = window.location.pathname;
        
        if (path == "/" || path === "") {
            // UrlMapping: "/"
			appPadService.create();
        } else {
            // UrlMapping: "/$id"
            var id = path.substr(1);
			appPadService.show(id, function (pad) {
                $scope.id = pad.id;
                $scope.pad = pad;

                appFileService.init(pad);
            });
        }
	};
       
    $scope.init();
});

angular.module("ats-pad").controller("FileController", function ($scope, $log, appFileService, appContextService) {
    $scope.service = appFileService;
});