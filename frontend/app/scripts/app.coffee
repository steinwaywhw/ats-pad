'use strict'

angular.module('atsPadApp', ['ngCookies', 'ngResource', 'ngSanitize', 'ngRoute'])
	.config ($routeProvider) ->
		$routeProvider

			.when '/about',
				templateUrl : 'views/about.html'

			.when '/help',
				templateUrl : 'views/help.html'

			.when '/:id?',
				templateUrl : 'views/main.html'
				controller  : 'MainCtrl'	

			.when '/:id/fork',
				templateUrl : 'views/main.html'
				controller  : 'ForkCtrl'

			.otherwise
				redirectTo  : '/'

