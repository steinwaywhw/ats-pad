package atspad

class DockerWorker {

	String id

	String atspadid
	String cid
	String ip 
	String port 
	Long lastActive 
	String sid
	String mount

	/**
	 * Generate the worker id using sid + atspadid.
	 * atspadid should be a 1-1 mapping with 
	 * the dir containing ats source code. sid+atspadid
	 * should be a 1-1 mapping with docker worker. 
	 * @return worker id
	 */
	static String generateId(sid, atspadid) {
		return "worker:${sid}:${atspadid}"
	}

    static constraints = {
    }

    static mapping = {
        id generator:'assigned'
    }
}
