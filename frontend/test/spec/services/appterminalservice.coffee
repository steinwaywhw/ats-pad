'use strict'

describe 'Service: appTerminalService', ->

  # load the service's module
  beforeEach module 'atsPadApp'

  # instantiate service
  appTerminalService = {}
  beforeEach inject (_appTerminalService_) ->
    appTerminalService = _appTerminalService_

  it 'should do something', ->
    expect(!!appTerminalService).toBe true
