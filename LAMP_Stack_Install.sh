#!/bin/bash

# ------------[20/7/2015]---------------#
#										#
#	Alex McPhee							#
#   CentOS-6-Quick-Install-Scripts		#
#	LAMP Stack							#
#	HTTPD, PHP, MYSQL, MYSQL-SERVER.	#
#										#
#---------------------------------------#

clear

echo 'Going to install the LAMP stack on your machine, here we go...'
echo '------------------------'
read -p "MySQL Password: " mysqlPassword
read -p "Retype password: " mysqlPasswordRetype

rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm 

yum install -y httpd php55w php55w-opcache mysql mysql-server

chkconfig mysql-server on
chkconfig httpd on

/etc/init.d/mysqld restart

while [[ "$mysqlPassword" = "" && "$mysqlPassword" != "$mysqlPasswordRetype" ]]; do
  echo -n "Please enter the desired mysql root password: "
  stty -echo
  read -r mysqlPassword
  echo
  echo -n "Retype password: "
  read -r mysqlPasswordRetype
  stty echo
  echo
  if [ "$mysqlPassword" != "$mysqlPasswordRetype" ]; then
    echo "Passwords do not match!"
  fi
done

/usr/bin/mysqladmin -u root password $mysqlPassword

 iptables -I INPUT 4 -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
 /etc/init.d/iptables save

clear
echo 'Okay.... apache, php and mysql is installed, running and set to your desired password'