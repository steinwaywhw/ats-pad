'use strict'

angular.module('atsPadApp').directive 'appMarkdown', (appMarkdownService) ->
	
	restrict: 'AE'
	link: (scope, element, attrs) -> 
		element.replaceWith appMarkdownService.toHtml element.html()
