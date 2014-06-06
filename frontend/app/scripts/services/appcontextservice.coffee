'use strict'

angular.module('atsPadApp').factory 'appContextService', ->
    
    id = null

    # Public API here
    {
    	getId: () -> id 
    	setId: (v) -> id = v
    	isReady: () -> id isnt null
    }
