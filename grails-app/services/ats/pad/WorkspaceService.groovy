package ats.pad
import javax.annotation.PostConstruct
import grails.transaction.Transactional

@Transactional
class WorkspaceService {

	def grailsApplication

	def snapshot = [:]
	def timer = new Timer()
	def interval
	def basedir

    @PostConstruct
    def init() {
        basedir = grailsApplication.config.atspad.worker.base
        interval = grailsApplication.config.atspad.workspace.watchInterval
    }
    
    def allocate(atspadid, files) {
    	assert atspadid
    	assert files
    	
    	log.info "Allocating workspace for ${atspadid}"

    	def path = this.generatePath(atspadid)
    	def cwd = new File(path)

    	assert !cwd.exists()
    	assert cwd.mkdirs()

    	files.each { key, value ->
    	    log.trace "Writing file ${key}"
    	    
    		def file = new File(path, key)
    		assert file.createNewFile()
    		file << value
    	}

    	return cwd
    }

    def reallocate(atspadid, files) {
    	assert atspadid
    	assert files
    	
    	log.info "Reallocate workspace for ${atspadid}"

    	def path = this.generatePath(atspadid)
    	def cwd = new File(path)

    	assert cwd.exists()
    	cwd.listFiles()*.delete()

    	assert cwd.listFiles().length == 0

    	files.each { key, value ->
    	    log.trace "Writing file ${key}"
    		def file = new File(path, key)
    		assert file.createNewFile()
    		file << value
    	}

    	return cwd
    }

    def generatePath(atspadid) {
    	return "${this.basedir}/${atspadid}"
    }

    def reclaim(atspadid) {
    	assert atspadid
    	assert files
    	
    	log.info "Reclaiming workspace for ${atspadid}"

    	def path = this.generatePath(atspadid)
    	def cwd = new File(path)

    	assert cwd.exists()

    	return cwd.deleteDir()
    }

    /**
     * Run the monitoring service
     * @param  atspadid 
     * @param  cwd      dir to watch
     * @param  callback lam (id:atspadid, f:file, state:string)
     * @return          TimerTask or null
     */
    def runWatch(atspadid, cwd, callback) {
    	// check if cwd exists
    	def dir = new File(cwd)
    	if (!dir.exists())
    		return null

    	assert atspadid

    	// list all current files
    	def files = new File(path).listFiles(fileFilter);
    	def checked = []

    	// check for add and modify
    	dir.eachFileRecurse { file ->
    		checked << file

    		// newly added
    		if (snapshot[file] == null) {
    			dir << [file:file.lastModified()]
    			callback(atspadid, file, "added")
    		}

    		// modified
    		else if (snapshot[file] != file.lastModified()) {
    			snapshot[file] = file.lastModified()
    			callback(atspadid, file, "modified")
    		} 
    	}
    	
    	// deleted
    	(dir - checked).each { file ->
    		dir.remove(file)
    		callback(atspadid, file, "deleted")
    	}

    	// run again with the callback
    	this.timer.runAfter(this.interval, {
    		this.runWatch(atspadid, cwd, callback)
    	})
    }

    def setupWatch(atspadid, cwd, callback) {
    	def dir = new File(cwd)
    	assert dir.exists()
    	assert atspadid

    	dir.eachFileRecurse { file ->
    		snapshot << [file:file.lastModified()]
    	}

    	this.timer.runAfter(this.interval, {
    		this.runWatch(atspadid, cwd, callback)
    	})
    }

    // def callback(atspadid, file, states) {
    // 	switch (states) {
    // 		case "added":
    // 		case "modified":
    // 		case "deleted":
    // 	}
    // }
}
