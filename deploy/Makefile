all:
	cd ../frontend && grunt build
	cp -r ../frontend/dist/* ../web-app 
	mv ../web-app/index.html ../grails-app/views/index.gsp
	cd ../ && grails prod war
	vagrant provision

war:
	cd ../ && grails prod war
	vagrant provision