'use strict'

describe 'Service: appTermClient', ->

  # load the service's module
  beforeEach module 'atsPadApp'

  # instantiate service
  appTermClient = {}
  beforeEach inject (_appTermClient_) ->
    appTermClient = _appTermClient_

  it 'should do something', ->
    expect(!!appTermClient).toBe true
