'use strict'

describe 'Service: appMarkdownService', ->

  # load the service's module
  beforeEach module 'atsPadApp'

  # instantiate service
  appMarkdownService = {}
  beforeEach inject (_appMarkdownService_) ->
    appMarkdownService = _appMarkdownService_

  it 'should do something', ->
    expect(!!appMarkdownService).toBe true
