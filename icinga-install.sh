#!/bin/bash -

#title           :icinga-install.sh
#description     :This script will proform a guided install.
#author		 	 :Alex McPhee
#date            :11082015
#version         :0.2    
#usage		 	 :'FROM DESKTOP' ]# ./<FILEDIR/FILE-TO-RUN>
#notes           :Ignore pnp4nagios, as this requires a local 'nagios core' to have been installed.
#				 :this script installs icinga 1.10.1. this version will soon if not already, be deprecated.
# Linux Version  :CentOS release 6.7 (Final)		
#==============================================================================
# prerequisite for installing: On CentOS 6.7 - 'minimal-Desktop install'   
# net install img location
#	http://centos.serverspace.co.uk./centos/6.6/os/x86_64/
#	
# A Desktop install is required as their will be 
#	# pop-up terminals during the install script.
#	
# after following script you will need to add the following to the iptables.
#	# this will enable the host to except external connections on port 80
#	
#	]# iptabels -I INPUT 4 -p tcp -m -state --state NEW -m tcp --dport 80 -j ACCEPT
#	]# sudo /etc/init.d/iptables save
##==============================================================================
 
#   Installation of packages
yum install xterm
yum install php php-cli rrdtool librrds-perl php5-gd gcc make tomcat6 perl-* perl *-perl php-pear php-xmlrpc php-xsl php-pdo php-soap php-gd php-ldap php-mysql httpd gcc glibc glibc-common gd gd-devel libjpeg libjpeg-devel libpng libpng-devel net-snmp net-snmp-devel net-snmp-utils mysql mysql-server libdbi libdbi-devel libdbi-drivers libdbi-dbd-mysql postgresql postgresql-server libdbi libdbi-devel libdbi-drivers libdbi-dbd-pgsql
 
 
# Creation  of directory for installation
xterm -e mkdir /icinga
 
# Creation of user account
useradd -m icinga
 
echo "
 
# Enter password for icinga user
the password is : icinga
 
 
******     Close windows if you finish  ******
 
" > /icinga/tempo
 
xterm -e vim /icinga/tempo&
xterm -e passwd icinga&
groupadd icinga
groupadd icinga-cmd
usermod -a -G icinga-cmd icinga
usermod -a -G icinga-cmd apache
 
 
# Download of sources 
cd /usr/src/
 
xterm -e wget http://garr.dl.sourceforge.net/project/icinga/icinga-web/1.10.0/icinga-web-1.10.0.tar.gz&
xterm -e wget http://www.nagios-plugins.org/download/nagios-plugins-1.5.tar.gz&
xterm -e wget http://garr.dl.sourceforge.net/project/icinga/icinga/1.10.1/icinga-1.10.1.tar.gz&
wget http://mirror.opendoc.net/icinga-repository/icinga-reports-1.6.0.tar.gz
 
cd /usr/src/
 
 
clear
 
echo "
 
*****   Downloads is process *****
 
"
wait
 

# Compilation and installation of Icinga Core
cd /usr/src/
tar xzvf icinga-1.10.1.tar.gz
cd icinga-1.10.1/
./configure
 
make all
 
make install
make install-init
make install-config
make install-eventhandlers
make install-commandmode
make install-idoutils
 
 
cd /usr/local/icinga/etc/
cp idomod.cfg-sample idomod.cfg
cp ido2db.cfg-sample ido2db.cfg
 
 
/etc/init.d/mysqld start
 
 
echo "
 
# Initialize data base enter following commands on mysql
##############################
CREATE DATABASE icinga;
    GRANT USAGE ON icinga.* TO 'icinga'@'localhost'
    IDENTIFIED BY 'icinga'
    WITH MAX_QUERIES_PER_HOUR 0
    MAX_CONNECTIONS_PER_HOUR 0
    MAX_UPDATES_PER_HOUR 0;
    GRANT SELECT, INSERT, UPDATE, DELETE, DROP, CREATE VIEW, INDEX, EXECUTE
    ON icinga.* TO 'icinga'@'localhost';
    FLUSH PRIVILEGES;
quit
##############################
     
******     Close windows if you finish  ******
" > /icinga/tempo
 
xterm -e vim /icinga/tempo&
 
mysql -u root
 
wait
 
cd /usr/src/icinga-1.10.1/module/idoutils/db/mysql/
mysql -u root icinga < mysql.sql
 

# Management of broken modules
cp /usr/local/icinga/etc/modules/idoutils.cfg-sample /usr/local/icinga/etc/modules/idoutils.cfg
  

# Configurationof classic web interface
cd /usr/src/icinga-1.10.1/
 
make cgis
make install-cgis
make install-html
make install-webconf
 
# Creation of admin account
 
echo "

# Enter password for icingaadmin user
 
# That password will be use for web interface
 
 
******     Close windows if you finish  ******
 
" > /icinga/tempo
 
xterm -e vim /icinga/tempo&
 
xterm -e htpasswd -c /usr/local/icinga/etc/htpasswd.users icingaadmin&
 
wait
 
# Restartweb service
service httpd restart
 
 
# Compilation and installation of plug-in for nagios
cd /usr/src
tar xvzf nagios-plugins-1.5.tar.gz 
cd nagios-plugins-1.5  
./configure --prefix=/usr/local/icinga \
    --with-cgiurl=/icinga/cgi-bin \
    --with-nagios-user=icinga --with-nagios-group=icinga
make
make install
     
# Temporary modification of system settings
getenforce
setenforce 0
 
chcon -R -t httpd_sys_script_exec_t /usr/local/icinga/sbin/
chcon -R -t httpd_sys_content_t /usr/local/icinga/share/
 
 
# Restart and save new services 
for i in mysqld ido2db icinga httpd; do /etc/init.d/$i restart; done
 
for i in mysqld ido2db icinga httpd; do chkconfig --add $i; chkconfig $i on; done
 
 
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
 
 
 
#   ICINGA WEB

# Compilation and Installation 
cd /usr/src/
tar xvzf icinga-web-1.10.0.tar.gz
cd /usr/src/icinga-web-1.10.0/
./configure --prefix=/usr/local/icinga-web --with-db-type=mysql --with-db-host=localhost --with-db-port=3306 --with-db-name=icinga_web --with-db-user=icinga_web --with-db-pass=icinga_web
 
make install
make install-apache-config
make install-javascript
make install-done
make testdeps
                 
 
# Configuration of Data Base for Icinga Web 
echo "
 
# Initialize data base enter following commands on mysql
##############################
CREATE DATABASE icinga_web;
    GRANT USAGE ON *.* TO 'icinga_web'@'localhost'
    IDENTIFIED BY 'icinga_web'
    WITH MAX_QUERIES_PER_HOUR 0 
    MAX_CONNECTIONS_PER_HOUR 0 
    MAX_UPDATES_PER_HOUR 0;
    GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, INDEX ON icinga_web.* TO 'icinga_web'@'localhost';
    FLUSH PRIVILEGES;
    quit
##############################
     
******     Close windows if you finish  ******
" > /icinga/tempo
 
xterm -e vim /icinga/tempo&
 
mysql -u root
 
wait
     
echo "
 

# Initialize data base
 
accept all
 

******     Close windows if you finish  ******
" > /icinga/tempo
 
xterm -e vim /icinga/tempo&
xterm -e make db-initialize&
 
wait
 
 
for i in mysqld ido2db icinga httpd crond snmpd snmptrapd ; do /etc/init.d/$i restart; done
 
 
echo "
# Change idomod.cfg 
#use_ssl=1
#output_type=tcpsocket
#output=127.0.0.1
 
# Change ido2db.cfg
#use_ssl=1
#socket_type=tcp 
  
# To save => Echap :wq
  
******     Close windows if you finish  ******
 
" > /icinga/tempo
 
xterm -e vim /icinga/tempo&
xterm -e vim /usr/local/icinga/etc/ido2db.cfg&
xterm -e vim /usr/local/icinga/etc/idomod.cfg&
 
wait
 
echo "
# *******  idoutils.cfg **********
# Add/Upadate
 
# define module{
#        module_name    ido_mod
#        path           /usr/local/icinga/lib/idomod.so
#        module_type    neb
#        args           config_file=/usr/local/icinga/etc/idomod.cfg
#        }
  
# To save => Echap :wq
  
******     Close windows if you finish  ******
 
" > /icinga/tempo
 
xterm -e vim /icinga/tempo&
 
xterm -e vim /usr/local/icinga/etc/modules/idoutils.cfg& 
 
wait
 
 
echo "
 
# To save system settings
# change
SELINUX=enforcing 
#by
SELINUX=disabled 
 
******************************************
 

# To save => Echap :wq
  

******     Close windows if you finish  ******
 
" > /icinga/tempo
 
xterm -e vim /icinga/tempo&
 
xterm -e vim /etc/sysconfig/selinux&
 
wait
 
for i in mysqld ido2db icinga httpd crond snmpd snmptrapd npcd; do /etc/init.d/$i restart; done
 
for i in mysqld ido2db icinga httpd crond snmpd snmptrapd npcd; do chkconfig --add $i; chkconfig $i on; done
