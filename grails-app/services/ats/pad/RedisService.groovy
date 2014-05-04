package ats.pad
import javax.annotation.PostConstruct

import redis.clients.jedis.*
import redis.clients.jedis.exceptions.*

class RedisService {
	def grailsApplication

	def redis = null

    def methodMissing(String name, args) {
        withRedis { Jedis redis ->
            redis.invokeMethod(name, args)
        }
    }

    // void propertyMissing(String name, Object value) {
    //     withRedis { Jedis redis ->
    //         redis.set(name, value.toString())
    //     }
    // }

    // Object propertyMissing(String name) {
    //     withRedis { Jedis redis ->
    //         redis.get(name)
    //     }
    // }

    def withRedis(Closure closure) {
    	if (!redis) {
    		def ip = grailsApplication.config.atspad.redis.guestIp
    		def port = grailsApplication.config.atspad.redis.guestPort

    		redis = new Jedis(ip, port)
    	}

        try {
            def ret = closure(redis)
            return ret
        } catch(JedisConnectionException jce) {
            throw jce
        } catch(Exception e) {
            throw e
        }
    }
}
