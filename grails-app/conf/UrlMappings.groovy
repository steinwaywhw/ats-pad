class UrlMappings {

	static mappings = {
		"/api/uuid"(controller:"main", action:"uuid")
        "/api/docker/$atspadid/$action"(controller:"docker")
		//"/api/$id/$action?/$fileid?"(controller:"main")

		"/"(view:"/index")
        "/$id"(view:"/index")
        "500"(view:'/error')

        //$id/console

        //api/pad/typecheck
        //api/pad/run
        //api/pad/$id?(.$format)?/file?
        //api/pad/(index)
        //api/pad/$id
        "/api/pad/"(controller:"pad", action:"create")
        "/api/pad/$id"(controller:"pad") {
            action = [GET:"show", DELETE:"delete"]
        }
        "/api/pad/$id/js"(controler:"pad", action:"embed")
        "/api/pad/$id/file"(controller:"pad") {
            action = [GET:"refersh", POST:"upload"]
        }

        "/$controller/$action?/$id?(.$format)?"{
            constraints {
                // apply constraints here
            }
        }
	}
}
