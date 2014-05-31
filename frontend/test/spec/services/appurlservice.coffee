'use strict'

describe 'Service: appUrlService', ->

  # load the service's module
  beforeEach module 'atsPadApp'

  # instantiate service
  appUrlService = {}
  beforeEach inject (_appUrlService_) ->
    appUrlService = _appUrlService_

  it 'should do something', ->
    expect(!!appUrlService).toBe true
