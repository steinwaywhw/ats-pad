'use strict'

describe 'Directive: appReadme', ->

  # load the directive's module
  beforeEach module 'atsPadApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<app-readme></app-readme>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the appReadme directive'
