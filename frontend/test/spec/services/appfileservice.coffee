'use strict'

describe 'Service: appFileService', ->

  # load the service's module
  beforeEach module 'atsPadApp'

  # instantiate service
  appFileService = {}
  beforeEach inject (_appFileService_) ->
    appFileService = _appFileService_

  it 'should do something', ->
    expect(!!appFileService).toBe true
