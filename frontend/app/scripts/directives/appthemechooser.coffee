'use strict'

angular.module('atsPadApp')
  .directive 'appThemeChooser', ($http) ->

	themes = []
	css = null
	select = null 

	init = ->
		request = $http.get("http://api.bootswatch.com/3/")
		request.success (data) ->
			themes = data.themes
			select.empty()
			for theme, index in themes 
				select.append($("<option/>").val(index).text(theme.name))

	# return
	{
		restrict: 'A'
		link: (scope, element, attrs) ->

			css = $("##{attrs.idCss}")
			select = element

			init()

			element.on "change", ->
				index = $(this).val()
				theme = themes[index]
				css.attr("href", theme.cssCdn)
			
			
	}