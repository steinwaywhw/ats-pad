echo "updating apt-get"
apt-get update
apt-get upgrade -y

echo "installing utilities"
apt-get install -y git curl wget ruby build-essential ruby1.9.1-dev 

echo "installing remote syslog"
gem install remote_syslog
cp /remote_syslog /etc/init.d/remote_syslog
cp /log_files.yml /etc/log_files.yml
chmod 755 /etc/init.d/remote_syslog
rm /remote_syslog 
rm /log_files.yml 

echo "installing tomcat"
apt-get install -y tomcat7 tomcat7-admin
mv /var/lib/tomcat7/webapps/ROOT /var/lib/tomcat7/webapps/oldroot

echo "installing docker"
apt-get install -y docker.io
ln -sf /usr/bin/docker.io /usr/bin/docker
gpasswd -a vagrant docker
gpasswd -a tomcat7 docker

echo "start service"
service remote_syslog restart
service tomcat7 restart

