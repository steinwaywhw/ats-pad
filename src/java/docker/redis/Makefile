


build:
	docker build -t redisimg .


run:
	docker run -t -i --name redisclient --link redisserver:db redisimg redis-cli -h $$DB_PORT_6379_TCP_ADDR

runserver:
	docker run -d -p 6379:6379 --name redisserver redisimg redis-server

clean:
	docker rm redisclient

stop:
	docker stop $$(docker ps -q)

