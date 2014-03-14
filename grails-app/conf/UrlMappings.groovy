class UrlMappings {

	static mappings = {
		"/api/uuid"(controller:"main", action:"uuid")
		"/api/$id/$action?/$fileid?"(controller:"main")
		"/"(view:"/index")
        "500"(view:'/error')

        "/$controller/$action?/$id?(.$format)?"{
            constraints {
                // apply constraints here
            }
        }
	}
}
