'use strict'

angular.module('atsPadApp')
  .directive('appFileList', ->
    template: '<div></div>'
    restrict: 'E'
    link: (scope, element, attrs) ->
      element.text 'this is the appFileList directive'
  )
