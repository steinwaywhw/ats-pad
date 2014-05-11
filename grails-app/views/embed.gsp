<!DOCTYPE HTML>
<html ng-app="ats-pad-embed">
<head>
	<title>Online Editor for ATS</title>

	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">

	<script src="http://ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"></script>
	<script src="http://ajax.googleapis.com/ajax/libs/angularjs/1.2.12/angular.min.js"></script>
	<script src="http://ajax.googleapis.com/ajax/libs/angularjs/1.2.12/angular-route.min.js"></script>
	<script src="http://ajax.googleapis.com/ajax/libs/angularjs/1.2.12/angular-sanitize.min.js"></script>

	<script src="http://cdn.jsdelivr.net/ace/1.1.3/min/ace.js"></script>

	<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>
	<link href="http://netdna.bootstrapcdn.com/font-awesome/4.0.3/css/font-awesome.css" rel="stylesheet">
	<link rel="stylesheet" type="text/css" href="http://netdna.bootstrapcdn.com/bootswatch/3.1.1/superhero/bootstrap.min.css">
    <script src="http://cdnjs.cloudflare.com/ajax/libs/spin.js/2.0.0/spin.min.js"></script>

    <link rel="stylesheet" href="http://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.0/styles/railscasts.min.css">
    <script src="http://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.0/highlight.min.js"></script>
    <script src="/js/markdown.min.js"></script>

    <style type="text/css">


    </style>
</head>

<body class="container-fluid" ng-controller="MainController">

	<div class="row">
		<div class="col-md-12">
			<ul class="nav nav-tabs">
				<li ng-repeat="filename in pad.filenames" ng-class="{active:$first}">
					<a href="{{'#' + filename2id(filename)}}" data-toggle="tab">{{filename}}</a>
				</li>
			</ul>

			<div class="tab-content">
				<div ng-repeat="file in pad.files" ng-class="{'tab-pane': true, active:$first}" id="{{filename2id(pad.filenames[$index])}}">
					<p ng-bind-html="pad.highlights[$index]"></p>
				</div>
			</div>
		</div>
	</div>

	<script type="text/javascript">
		var app = angular.module("ats-pad-embed",["ngSanitize"]);

		app.controller("MainController", function ($scope, $log, $http) {
			$scope.id = "${id}"; //come from gsp modal

			$scope.filename2id = function (filename) {
				return filename.replace(".", "-", "g");
			}
			
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
					filenames: filenames,
				};
			};

			var highlight = function (pad) {
				highlights = [];
				pad.files.forEach(function (e) {
					highlights.push('<pre class="hljs"><code>' + $scope.hljs.highlightAuto(e).value + '</code></pre>');
				});

				pad.highlights = highlights;
				return pad;
			};

			var marker = function () {};

			var show = function (id, callback) {
				$log.debug("Loading " + id);

				$http
				.get("/api/pad/" + id)
				.success(function (pad, status) {
					$log.debug("Success: " + id);
					callback(fromserver(pad));
				})
				.error(function (data, status) {
					$log.debug("Error: " + data);
				});
			};

			show($scope.id, function (pad) {
				$scope.hljs = hljs;
				$scope.pad = highlight(pad);
				
			});



		})
	</script>

<!--

		<script type="text/javascript">
			var padid = '2bVzJ2eILazkosHh';
			var apiurl = "http://localhost:8080/api/pad/" + padid;

			$.getJSON(apiurl, function (data) {
				generateHtml(data);
			});

			var generateHtml = function (pad) {
				var container = $("#" + padid);
				var files = [];
				$.each(pad.files, function (key, value) {
					var code = $("<code>").text(value);
					var pre = $("<pre>").append(code);
					container.append(pre);
				});
			}
		</script>

		<div id="2bVzJ2eILazkosHh"></div>




<script src="https://cdnjs.cloudflare.com/ajax/libs/less.js/1.7.0/less.min.js"></script>


<script type="text/javascript">
var app = angular.module("ats-pad-embed");

app.controller("MainController", function ($scope, $http, $location) {



	$http
	.get()
});

</script>
-->
</body>
</html>
