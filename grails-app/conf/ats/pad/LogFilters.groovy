package ats.pad

class LogFilters {

    def filters = {
        all(controller:'*', action:'*') {
            before = {
                log.info "REQ: ${request.url}"
            }
            after = { Map model ->

            }
            afterView = { Exception e ->

            }
        }
    }
}
