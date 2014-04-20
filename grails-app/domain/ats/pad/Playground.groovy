package ats.pad
import org.apache.commons.lang3.RandomStringUtils

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
        	id = RandomStringUtils.randomAlphanumeric(16)
    }
}
