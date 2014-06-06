'use strict'

describe 'Directive: appAffix', ->

  # load the directive's module
  beforeEach module 'atsPadApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<app-affix></app-affix>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the appAffix directive'
