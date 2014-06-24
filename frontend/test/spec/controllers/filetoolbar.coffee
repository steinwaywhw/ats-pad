'use strict'

describe 'Controller: FiletoolbarCtrl', ->

  # load the controller's module
  beforeEach module 'atsPadApp'

  FiletoolbarCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    FiletoolbarCtrl = $controller 'FiletoolbarCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', ->
    expect(scope.awesomeThings.length).toBe 3
