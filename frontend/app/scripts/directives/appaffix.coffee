'use strict'

angular.module('atsPadApp').directive 'appAffix', (appNotificationService, $timeout) ->

	notifier = appNotificationService

	# return
	restrict: 'A'
	link: (scope, element, attrs) ->

		affix = $(element)
		parent = $(element).parent()

		isReady = ->
			$(attrs.topLimit).length > 0 and $(attrs.bottomLimit).length > 0

		fixedWidth = ->
			width = parent.width()
			$(element).width(width)

		toScreen = (top) -> top - $(window).scrollTop()
		topLimit = -> $(attrs.topLimit).offset()?.top
		bottomLimit = -> toScreen $(attrs.bottomLimit).offset()?.top
		binding = ->
			$(window).resize ->
				$timeout -> fixedWidth()

			$(window).scroll (e) ->
				if isReady()
					affixTop = topLimit()     	
					affixTop = bottomLimit() if affixTop > bottomLimit()
					affixTop = 10 if affixTop < 10

					affix.css 'top', affixTop	

			# TODO
			$('.ats-pad-header').bind "DOMSubtreeModified", ->
				if isReady()
					affixTop = topLimit()     	
					affixTop = bottomLimit() if affixTop > bottomLimit()
					affixTop = 10 if affixTop < 10

					affix.css 'top', affixTop	

			$(document).ready ->
				if isReady() 
					$timeout ->
						affix.css 'top', topLimit()
						fixedWidth()


		if not $(attrs.topLimit).offset()?.top? or not $(attrs.bottomLimit).offset()?.top?
			notifier.debug "Can't init app-affix"
		else 
			affix.css('top', topLimit())
			affix.css('z-index', 1000)
			binding()
			
		
	  
