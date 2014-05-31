'use strict'

describe 'Service: appNotificationService', ->

  # load the service's module
  beforeEach module 'atsPadApp'

  # instantiate service
  appNotificationService = {}
  beforeEach inject (_appNotificationService_) ->
    appNotificationService = _appNotificationService_

  it 'should do something', ->
    expect(!!appNotificationService).toBe true
