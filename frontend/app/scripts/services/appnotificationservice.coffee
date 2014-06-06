'use strict'

angular.module('atsPadApp').factory 'appNotificationService', ($log) ->
	
	qError = []
	qSuccess = []
	qDebug = []

	DEBUG = true
	
	{
		error: (msg, data = null) ->
			qError.push(msg)
			if DEBUG then $log.debug(msg)

		debug: (msg) ->
			#qDebug.push(msg)
			if DEBUG then $log.debug(msg)

		success: (msg) ->
			qSuccess.push(msg)
			if DEBUG then $log.debug(msg)

		queues: () ->
			{
				e: qError
				s: qSuccess
				d: qDebug
			}
	}
