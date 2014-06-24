'use strict'

angular.module('atsPadApp').factory 'appMarkdownService', (appNotificationService) ->

	notifier = appNotificationService

	if not marked? or not hljs?
		notifier.error "marked/highlightjs is not available"

	marked.setOptions
		gfm: true
		tables: true
		breaks: false
		pedantic: false
		sanitize: false
		smartLists: true
		smartypants: false
		highlight: (code) -> hljs.highlightAuto(code).value

	# Public API here
	{
		toHtml: (md) -> marked(md)
		addClass: (element) ->
			$(element).find("table").addClass("table")
	}
