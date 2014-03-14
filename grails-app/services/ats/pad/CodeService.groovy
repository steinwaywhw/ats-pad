package ats.pad
import org.apache.commons.lang.RandomStringUtils
import grails.transaction.Transactional


@Transactional
class CodeService {

    def writeTempFile(String name, String code) {
    	def temp = new File(name)
    	temp.withWriter { out ->
    		out.write(code)
    	}

    	return temp
    }

    def compile(List<File> files) {

    	def fs = files*.getAbsolutePath().join(" ") 
    	def cmd = ['patscc', '-o', RandomStringUtils.randomAlphabetic(20)] << fs as ArrayList<String>
    	def pb = new ProcessBuilder(cmd)
    	def p = pb.start()

		p.waitFor()

		def stdout = new BufferedReader(new InputStreamReader(p.getInputStream()))
		def stderr = new BufferedReader(new InputStreamReader(p.getErrorStream()))

		def line = []
		
		line << stdout.getText().tokenize("\n")
		line << stderr.getText().tokenize("\n")

		p.destroy()

		return line.flatten()
		//return "patscc -o " + RandomStringUtils.randomAlphabetic(16) + " " + files*.getAbsolutePath().join(" ")
    }
}
