'use strict'

angular.module('atsPadApp').directive 'appAffix', ->

	restrict: 'A'
	link: (scope, element, attrs) ->
		
		affix = $(element)
		parent = $(element).parent()
		
		fixedWidth = ->
			width = parent.width()
			$(element).width(width)
			
		toScreen = (top) -> top - $(window).scrollTop()
		topLimit = -> $(affix.attr 'data-top-limit').offset().top
		bottomLimit = -> toScreen $(affix.attr 'data-bottom-limit').offset().top
		
		affix.css('top', topLimit())
		
		$(window).scroll (e) ->
			affixTop = topLimit()     	
			affixTop = bottomLimit() if affixTop > bottomLimit()
			affixTop = 10 if affixTop < 10
			
			affix.css 'top', affixTop	
			
		$('body').bind "DOMSubtreeModified", ->
			affixTop = topLimit()     	
			affixTop = bottomLimit() if affixTop > bottomLimit()
			affixTop = 10 if affixTop < 10
			
			affix.css 'top', affixTop	
			
		$(document).ready ->
			affix.css 'top', topLimit()
			fixedWidth()

  
