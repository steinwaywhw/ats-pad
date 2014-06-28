class UrlMappings {

	static mappings = {
		//"/api/uuid"(controller:"main", action:"uuid")
        //"/api/docker/$atspadid/$action"(controller:"docker")
        //"/api/docker/$id/url"(controller:"docker", action:"url")
		//"/api/$id/$action?/$fileid?"(controller:"main")

		"/"(view:"/index")
        // "/$id"(view:"/index")
        // "/$id/embed"(controller:"pad", action:"embed")
        // "/$id/download"(controller:"pad", action:"download")
        // "/$id/fork"(controller:"pad", action:"fork")

        
        
        // "500"(view:"/error")
        // "404"(view:"/error")

        //$id/console

        //api/pad/typecheck
        //api/pad/run
        //api/pad/$id?(.$format)?/file?
        //api/pad/(index)
        //api/pad/$id
        
        "/api/worker/cleanup"(controller:"pad", action:"cleanup")
        "/api/worker/$wid/$action"(controller:"worker")

        "/api/pad/"(controller:"pad", action:"create")
        "/api/pad/$id"(controller:"pad") {action = [GET:"show", DELETE:"delete"]}
        "/api/pad/$id/worker"(controller:"pad") {action = [GET:"url"]}
        
        // FIXME file should only return file, otherwise is the same as /api/pad
        "/api/pad/$id/file"(controller:"pad") {action = [GET:"syncToClient", POST:"syncToServer"]}
        "/api/pad/$id/file/$name"(controller:"pad") {action = [GET:"getFile", POST:"saveFile", DELETE:"deleteFile"]}
        "/api/pad/$id/file/download"(controller:"pad") {action = [GET:"download"]}
        "/api/pad/$id/fork"(controller:"pad", action:"fork")

        // "/$controller/$action?/$id?(.$format)?"{
        //     constraints {
        //         // apply constraints here
        //     }
        // }
	}
}
