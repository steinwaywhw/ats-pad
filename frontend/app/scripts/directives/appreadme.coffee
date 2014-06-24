'use strict'

angular.module('atsPadApp').directive 'appReadme', ($timeout, appFileService, appMarkdownService) ->

	templateUrl: 'views/partials/readme.html'
	restrict: 'A'
	link: (scope, element, attrs) ->
		scope.toggle = ->
			element.find(".panel-body").toggleClass("collapse")

		toWatch = (scope) ->
			if not scope.pad?
				title: "README"
				content: "Please add README for this pad"

			else 
				active = appFileService.active()
				filename = scope.pad.filenames[active]
				if appFileService.isReadme(filename) or appFileService.guessMode(filename)? is "ace/mode/markdown"

					content: scope.pad.filecontents[active]
					title: scope.pad.filenames[active]

				else
					index = (index for name, index in scope.pad.filenames when appFileService.isReadme(name))[0]
					
					content: scope.pad.filecontents[index]
					title: scope.pad.filenames[index]
							

		toDo = (newv, oldv, scope) ->
			if newv? 
				scope.title = newv.title
				scope.content = appMarkdownService.toHtml(newv.content)

		scope.$watch toWatch, toDo, true
		scope.$watch (-> element.find('article').html()), (newv, oldv, scope) -> appMarkdownService.addClass(element)