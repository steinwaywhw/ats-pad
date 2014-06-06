'use strict'

angular.module('atsPadApp').directive 'appFileList', ->

	setupLess = ->
		less.env = 'production'
		less.logLevel = 0

	onThemeChanged = (element, theme) ->
		parser = new less.Parser({})
		lessStyle = """
			@import url("/styles/bootswatch/#{theme.name.toLowerCase()}/variables.less");
			@import url("/styles/filelist.less.keep");
		"""
		
		parser.parse lessStyle, (error, root) ->
			cssStyle = root.toCSS()
			styleId = "dynStyle"
			style = """
				<style type="text/css" id="#{styleId}">
					#{cssStyle}
				</style>
			"""

			$("##{styleId}").remove()
			$(element).before(style)


	{
		templateUrl : 'views/partials/filelist.html'
		restrict    : 'A'
		replace     : false
		link		: (scope, element, attrs) ->
			scope.form =
				filenames : []

			sycnToForm = (n, o, scope) -> scope.form.filenames = n[..] if n?
			scope.$watch("pad.filenames", sycnToForm, true)

			setupLess()
			scope.$on "app_evt_theme_changed", (event, theme) -> onThemeChanged(element, theme)
	}

