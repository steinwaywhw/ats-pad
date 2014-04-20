Project Structure
==================

* atspad-ui
	An angular-js webapp in front of atspad-api.

* atspad-api
	A java web application running atspad API.

* atspad-proxy
	A public docker image running nodejs/bouncy proxy server.

* atspad-redis
	A private docker image running redis for storing proxy information.

* atspad-worker
	Private docker images serving development environments for users.
