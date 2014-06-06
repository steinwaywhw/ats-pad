'use strict'

describe 'Controller: FilelistCtrl', ->

  # load the controller's module
  beforeEach module 'atsPadApp'

  FilelistCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    FilelistCtrl = $controller 'FilelistCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', ->
    expect(scope.awesomeThings.length).toBe 3
