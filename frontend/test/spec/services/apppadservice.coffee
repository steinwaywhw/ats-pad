'use strict'

describe 'Service: appPadService', ->

  # load the service's module
  beforeEach module 'atsPadApp'

  # instantiate service
  appPadService = {}
  beforeEach inject (_appPadService_) ->
    appPadService = _appPadService_

  it 'should do something', ->
    expect(!!appPadService).toBe true
