package ats.pad
import java.util.UUID
import grails.converters.*
import groovy.json.*

class MainController {


    def run() {
		def pg = new Playground(request.JSON)    	
		def files = []

		pg.filenames.eachWithIndex() {file, i ->
			files.add(codeService.writeTempFile(file, pg.files[i]))
		}

		//def output = StringEscapeUtils.escapeJavaScript(codeService.compile(files))
		def output = codeService.compile(files)
    	render output as JSON
    }
}
