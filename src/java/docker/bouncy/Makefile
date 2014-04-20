build:
	docker build -t atspad/bouncy .

run:
	docker run -t -i -p 80:80 --rm --link worker:worker atspad/bouncy bash

runserver:
	docker run -d -p 80:80 --link worker:worker atspad/bouncy ./run.sh
