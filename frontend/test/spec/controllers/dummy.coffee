'use strict'

describe 'Controller: DummyCtrl', ->

  # load the controller's module
  beforeEach module 'atsPadApp'

  DummyCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    DummyCtrl = $controller 'DummyCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', ->
    expect(scope.awesomeThings.length).toBe 3
