echo "deploying application"
service tomcat7 stop
docker ps -qa | xargs docker stop
rm -rf /server
mkdir -p /server
chown -R tomcat7:tomcat7 /server
rm -rf /var/lib/tomcat7/webapps/ROOT /var/lib/tomcat7/webapps/ROOT.war
mv /ROOT.war /var/lib/tomcat7/webapps/
service remote_syslog restart
service tomcat7 restart

#docker build -t atspad/worker /var/lib/tomcat7/webapps/ROOT/WEB-INF/classes/docker/worker 
#docker build -t atspad/bouncy /var/lib/tomcat7/webapps/ROOT/WEB-INF/classes/docker/bouncy 
#docker build -t atspad/redis /var/lib/tomcat7/webapps/ROOT/WEB-INF/classes/docker/redis 