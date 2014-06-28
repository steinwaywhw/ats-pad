'use strict'

describe 'Controller: TerminalCtrl', ->

  # load the controller's module
  beforeEach module 'atsPadApp'

  TerminalCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    TerminalCtrl = $controller 'TerminalCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', ->
    expect(scope.awesomeThings.length).toBe 3
