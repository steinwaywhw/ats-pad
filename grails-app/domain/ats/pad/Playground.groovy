package ats.pad
import java.util.UUID

class Playground {

	String id
	
 	static hasMany = [files: String, filenames: String]	

    static constraints = {
    }

    static mapping = {
        id generator:'assigned'
    }

    def beforeInsert = {
        if (!id) 
        	id = UUID.randomUUID().toString()
    }
}
