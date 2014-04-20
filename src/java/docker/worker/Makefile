build:
	docker build -t atspad/worker .

run:
	docker run -t -i --rm atspad/worker bash

runserver:
	docker run -d -t --name worker atspad/worker node index.js