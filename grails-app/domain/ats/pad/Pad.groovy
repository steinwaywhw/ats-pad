package ats.pad

class Pad {

	/**
	 * atspad id
	 */
	String id

	/**
	 * File name to file content mappings
	 */
	Map files = ["Readme.md":"""
# Hello World\n\n
Welcome to ats-pad!\n
You can use [Markdown](https://daringfireball.net/projects/markdown/) syntax to write README.
"""
	]

	def cloneWithoutId() {
		def pad = new Pad()
		Map files = [:]
		this.files.each { key, value -> 
			files << [(new String(key)) : (new String(value))]
		}

		pad.files = files
		return pad 
	}

    static constraints = {
    }

    static mapping = {
    	id generator:'assigned'
    }
}
