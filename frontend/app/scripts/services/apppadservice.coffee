'use strict'

angular.module('atsPadApp')
	.factory 'appPadService', ($http, appUrlService, appNotificationService, appContextService) ->
	 

		notifier = appNotificationService

		###*
		 * [toserver description]
		 * @param  {[type]} pad [description]
		 * @return {[type]}     [description]
		###
		toserver = (pad) ->
			files = {}

			for filename, i in pad.filenames
				do (filename) ->
					files[filename] = pad.filecontents[i]

			{
				id: pad.id
				files: files
			}

		###*
		 * [fromserver description]
		 * @param  {[type]} pad [description]
		 * @return {[type]}     [description]
		###
		fromserver = (pad) ->
			filecontents = []
			filenames = []

			for name, content of pad.files 
				do (name, content) ->
					filecontents.push(content)
					filenames.push(name)

			{
				id: pad.id
				filecontents: filecontents
				filenames: filenames
			}

		# Public API here
		{
			create: (callback) ->
				notifier.debug "creating new pad"
				api = appUrlService.create 

				request = $http.get(api)

				request.success (id, status) ->
					notifier.debug "created: #{id}" 
					callback(id)

				request.error (data, status) ->
					notifier.error("failed to create pad", data)

			show: (id, callback) ->
				notifier.debug "loading pad #{id}"
				api = appUrlService.show

				request = $http.get(api)

				request.success (pad, status) ->
					notifier.debug "loaded: #{id}"
					callback(fromserver(pad))

				request.error (data, status) ->
					notifier.error("failed to load pad: #{id}", data)

			syncToServer: (pad) ->
				notifier.debug "syncing to server: #{pad.id}"
				api = appUrlService.syncToServer

				files = angular.toJson(toserver(pad))
				request = $http.post(api, data)

				request.success (data, status) ->
					notifier.success "saved"

				request.error (data, status) ->
					notifier.error("failed to save changes: #{pad.id}", data)

			syncToClient: (callback) ->
				notifier.debug "syncing from server"
				api = appUrlService.syncToClient

				request = $http.get(api)

				request.success (pad, status) ->
					notifier.success "refreshed"
					callback(fromserver(pad))

				request.error (data, status) ->
					notifier.error("failed to refresh", data)

			fork: (callback) ->
				notifier.debug "forking"
				api = appUrlService.forkApi

				request = $http.get(api)

				request.success (id, status) ->
					notifier.success "forked: #{id}"
					callback(id)

				request.error (data, status) ->
					notifier.error("failed to fork", data)

			delete: (callback) ->
				notifier.debug "deleting"
				api = appUrlService.delete

				request = $http.delete(api)

				request.success (data, status) ->
					notifier.success "deleted"
					callback(data)

				request.error (data, status) ->
					notifier.error("failed to delete", data)

			validate: (pad) ->
				result = true

				if not (pad?.id and pad?.filecontents and pad?.filenames)
					result = false
				else
					len1 = (c for c in pad.filecontents when c? and c isnt "").length
					len2 = (n for n in pad.filenames when n? and n isnt "").length

					result = false if not (len1 is 0 and len2 is 0)

				# return
				result
		}
