'use strict'

describe 'Controller: ForkCtrl', ->

  # load the controller's module
  beforeEach module 'atsPadApp'

  ForkCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    ForkCtrl = $controller 'ForkCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', ->
    expect(scope.awesomeThings.length).toBe 3
