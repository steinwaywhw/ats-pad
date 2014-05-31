'use strict'

angular.module('atsPadApp')
  .factory 'appMarkdownService', (appNotificationService) ->

  	notifier = appNotificationService

  	if not markdown?
  		notifier.error "markdown is not available"


    # Public API here
    {
    	toHtml: (md) -> markdown.toHTML(md)
    }
