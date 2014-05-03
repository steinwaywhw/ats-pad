build:
	docker build -t atspad/bouncy .

text:
	docker run -d -p 80:80 --expose 80 -e "ATSPAD_PROXY_PORT=80" atspad/bouncy node /root/index.js