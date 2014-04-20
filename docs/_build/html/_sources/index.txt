.. atspad documentation master file, created by
   sphinx-quickstart on Sat Apr 19 23:54:36 2014.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

The purpose of this is to document the project for further development.

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






Contents:

.. toctree::
   :maxdepth: 2



Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

