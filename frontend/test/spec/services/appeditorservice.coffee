'use strict'

describe 'Service: appEditorService', ->

  # load the service's module
  beforeEach module 'atsPadApp'

  # instantiate service
  appEditorService = {}
  beforeEach inject (_appEditorService_) ->
    appEditorService = _appEditorService_

  it 'should do something', ->
    expect(!!appEditorService).toBe true
