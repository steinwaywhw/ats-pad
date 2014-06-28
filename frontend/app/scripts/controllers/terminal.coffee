'use strict'

angular.module('atsPadApp').controller 'TerminalCtrl', ($scope, appTerminalService) ->
    $scope.refresh = -> appTerminalService.init(appTerminalService.id, appTerminalService.opts)