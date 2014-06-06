'use strict'

angular.module('atsPadApp', ['ngCookies', 'ngResource', 'ngSanitize', 'ngRoute'])
	.config ($routeProvider) ->
		$routeProvider
			
			.when '/loading',
				templateUrl : 'views/loading.html'
				controller  : 'LoadingCtrl'

			.when '/about',
				templateUrl : 'views/about.html'
				controller  : 'AboutCtrl'

			.when '/',
				templateUrl : 'views/main.html'
				controller  : 'MainCtrl'	


			.when '/fork',
				templateUrl : 'views/loading.html'
				controller  : 'LoadingCtrl'

			.otherwise
				redirectTo  : '/'

