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

    static constraints = {
    }

    static mapping = {
    	id generator:'assigned'
    }
}
