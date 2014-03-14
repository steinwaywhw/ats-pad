package ats.pad
import java.util.UUID
import grails.converters.*

class MainController {

	def codeService

    def uuid() {
    	render UUID.randomUUID().toString()
    }

    def run() {
		def pg = new Playground(request.JSON)    	
		def files = []

		pg.filenames.eachWithIndex() {file, i ->
			files.add(codeService.writeTempFile(file, pg.files[i]))
		}

		def output = codeService.compile(files)

    	render output as String
    }
}
