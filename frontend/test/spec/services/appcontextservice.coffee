'use strict'

describe 'Service: appContextService', ->

  # load the service's module
  beforeEach module 'atsPadApp'

  # instantiate service
  appContextService = {}
  beforeEach inject (_appContextService_) ->
    appContextService = _appContextService_

  it 'should do something', ->
    expect(!!appContextService).toBe true
