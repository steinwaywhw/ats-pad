package ats.pad
import org.apache.commons.lang.RandomStringUtils
import grails.transaction.Transactional

@Transactional
class CodeService {

    def writeTempFile(String name, String code) {
    	File temp = File.createTempFile(name, "");
    	temp.withWriter { out ->
    		out.write(code)
    	}

    	temp.deleteOnExit()
    	return temp
    }

    def compile(List<File> files) {

		//def p = Runtime.getRuntime().exec("patscc -o " + RandomStringUtils.random(20) + " " + files*.getAbsolutePath().join(" "));
		Locale.setDefault(Locale.ENGLISH)
		def p = Runtime.getRuntime().exec("ping -n 3 google.com")
		p.waitFor();

		def reader = new BufferedReader(new InputStreamReader(p.getInputStream()));

		def line = "";	
		def sb = new StringBuilder()		
		while ((line = reader.readLine()) != null) {
			sb.append(line + "\n");
		}

		return sb.toString();
    }
}
