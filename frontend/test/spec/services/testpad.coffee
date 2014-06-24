'use strict'

describe 'Service: testPad', ->

  # load the service's module
  beforeEach module 'atsPadApp'

  # instantiate service
  testPad = {}
  beforeEach inject (_testPad_) ->
    testPad = _testPad_

  it 'should do something', ->
    expect(!!testPad).toBe true
