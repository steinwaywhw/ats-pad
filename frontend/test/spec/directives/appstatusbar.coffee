'use strict'

describe 'Directive: appStatusBar', ->

  # load the directive's module
  beforeEach module 'atsPadApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<app-status-bar></app-status-bar>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the appStatusBar directive'
