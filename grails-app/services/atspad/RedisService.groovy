package atspad
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

    def withRedis(Closure closure) {
    	if (!redis) {

    		def ip = grailsApplication.config.atspad.redis.guestIp
    		def port = grailsApplication.config.atspad.redis.guestPort

            log.info("Connecting to Redis at ${ip}:${port}")

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
