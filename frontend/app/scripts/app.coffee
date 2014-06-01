'use strict'

angular.module('atsPadApp', ['ngCookies', 'ngResource', 'ngSanitize', 'ngRoute'])
	.config ($routeProvider) ->
		$routeProvider
			
			.when '/loading',
				templateUrl : 'views/loading.html'
				controller  : 'LoadingController'

			.when '/about',
				templateUrl : 'views/about.html'
				controller  : 'AboutCountroller'

			.when '/',
				templateUrl : 'views/main.html'
				controller  : 'MainCtrl'

			.when '/:filename',
				templateUrl : 'views/main.html'
				controller  : 'MainCtrl'	


			.when '/fork',
				templateUrl : 'views/loading.html'
				controller  : 'LoadingController'

			.otherwise
				redirectTo  : '/'

