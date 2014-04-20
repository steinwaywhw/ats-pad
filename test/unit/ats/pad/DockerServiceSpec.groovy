package ats.pad

import grails.test.mixin.TestFor
import spock.lang.Specification
import org.springframework.core.io.ClassPathResource

/**
 * See the API for {@link grails.test.mixin.services.ServiceUnitTestMixin} for usage instructions
 */
@TestFor(DockerService)
class DockerServiceSpec extends Specification {

    def setup() {
    	//service.stopall()
    }

    def cleanup() {
    	//service.stopall()
    }

    void "test docker build"() {
    	given:
    	File dockerfile = new ClassPathResource("docker/bouncy").getFile();

    	when:
    	def output = service.build(dockerfile.getAbsolutePath(), "atspad/bouncy")
    	log.info output

    	then:
    	output.contains("Successfully built")
    }

    void "test docker ps"() {
    	when:
    	def output = service.ps()
    	log.info output.join(" ")

    	then:
    	log.info "End"
    }

    void "test docker inspect"() {
    	given:
    	def cid = service.run(img="atspad/bouncy", cmd="./run.sh")

    	when:
    	def output = service.inspect(cid, "id")
    	log.info output.toString()

    	then:
    	log.info "End"
    }

    void "test stop all"() {
    	given:
    	def cids = service.ps()

    	when:
    	def test = service.stopall()

    	then:
    	test == cids
    }
}
