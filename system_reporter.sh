#!/bin/bash

# Alex Mcphee
# System Reporting Script
# providing server documentation
# 26/0815

#  Edit this path to point to the location you wish this report to be stored in.
ofile=/home/report/$HOSTNAME.html

# error file output, change to file location for debugging
errfile=/home/report/error.log

#ROOT CHECK - check if user is root. if not ask user to be root.
clear
ID=`id | sed 's/uid=\([0-9]*\)(.*/\1/'`
if [ "$ID" != "0" ] ; then
        echo "You must be root to execute $0."
        exit 1

fi

echo "Generating system stats please wait (can take a few minutes on slow systems)"
echo "File generated at $ofile on `date`"

echo "<HTML><BODY>">$ofile
echo "<H1>System Information</H1>">>$ofile
echo "<H3>">>$ofile
echo "$HOSTNAME" >>$ofile
echo "</H3>">>$ofile
echo " " >>$ofile
echo "File generated on `date`">>$ofile
echo "<TABLE border=\"1\"><TR><TD colspan=\"2\" bgcolor=#D1EEEE><H2>Hardware Config</H2>">>$ofile

echo "Hardware config...25%"

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Version</H3><TD><PRE>">>$ofile
cat /etc/*release >>$ofile
echo "" >>$ofile
uname -r >>$ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3> VAS or Boks </H3><TD><PRE>">>$ofile
if [ `ps -ef | grep -i bok |wc -l` -gt "3" ]
                        then
                        echo "BOKs Enabled Machine" >>$ofile
                        else
                        echo -e 'VAS Enabled Machine' >>$ofile
                fi

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Architect 32/64 Bit </H3><TD><PRE>">>$ofile
getconf LONG_BIT >> $ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Space Left on (/)</H3><TD><PRE>">>$ofile
echo "" >>$ofile
df -h / | grep -v Avail | awk '{ print $3 }' >>$ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Users Currently Logged In</H3><TD><PRE>">>$ofile
echo "" >>$ofile
users | wc -w >>$ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>UPTIME</H3><TD><PRE>">>$ofile
uptime >>$ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Veritas Information</H3><TD><PRE>">>$ofile
/sbin/vxdisk -o alldgs list   >>$ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>LVM Information</H3><TD><PRE>">>$ofile
echo "" >>$ofile
/usr/sbin/pvdisplay  >>$ofile
echo "" >>$ofile
/usr/sbin/vgdisplay >>$ofile
echo "" >>$ofile
/usr/sbin/lvdisplay>>$ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>No.Of Running Process</H3><TD><PRE>">>$ofile
ps ax | wc -l>>$ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>List Contents of /opt/ Dir</H3><TD><PRE>">>$ofile
# directory to search in.
search_dir=/opt
for entry in "$search_dir"/*
do
  echo "$entry" >>$ofile
done

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>No.Of Mount Points</H3><TD><PRE>">>$ofile
df -h | wc -l >>$ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Mount Points Information</H3><TD><PRE>">>$ofile
mount >> $ofile
df -h >> $ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>System Manufacturer</H3><TD><PRE>">>$ofile
echo "" >> $ofile
dmidecode --type system | grep -i manufacture >>$ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>CPU</H3><TD><PRE>">>$ofile
cat /proc/cpuinfo >>$ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Ethernet</H3><TD><PRE>">>$ofile
lspci | grep Ethernet >>$ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Interface</H3><TD><PRE>">>$ofile
ifconfig | grep eth | cut -c1-4 >interfaces.tmp
while read line
do
ethtool $line >>$ofile
done <interfaces.tmp
rm -f interfaces.tmp

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Filesystem</H3><TD><PRE>" >>$ofile
echo "<H4>Mountpoint</H4>" >>$ofile
df -h >>$ofile

echo "<H4>FStab</H4>" >>$ofile
cat /etc/fstab >>$ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Interrupts</H3><TD><PRE>" >>$ofile
cat /proc/interrupts >>$ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Hardware List</H3><TD><PRE>" >>$ofile
cat /etc/sysconfig/hwconf | grep desc: | sed 's/desc: "//' | sed 's/"//' >>$ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Boot Errors</H3><TD><PRE>" >>$ofile
dmesg -n1 >>$ofile
dmesg | grep -i error >>$ofile

echo "<TR valign=\"top\"><TD colspan=\"2\" bgcolor=#D1EEEE><H2>Network Config</H2><TD><PRE>">>$ofile

echo "Network config...50%"

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Interface Settings</H3><TD><PRE>" >>$ofile
ifconfig -a >>$ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>DNS Servers</H3><TD><PRE>" >>$ofile
cat /etc/resolv.conf | grep -i nameserver >>$ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Firewall rules</H3><TD><PRE>">>$ofile
iptables -L -v -n >>$ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Route</H3><TD><PRE>">>$ofile
route -n >>$ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Hosts</H3><TD><PRE>">>$ofile
cat /etc/hosts >>$ofile

echo "<TR valign=\"top\"><TD colspan=\"2\" bgcolor=#D1EEEE><H2>Server Status</H2><TD><PRE>">>$ofile

echo "Server Status...75%"

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Running Processes</H3><TD><PRE>">>$ofile
ps -eHf >>$ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Top 10 Memory consuming process</H3><TD><PRE>">>$ofile
ps axo %mem,comm,pid,euser | sort -nr | head -n 10 >>$ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Top 10 CPU consuming process</H3><TD><PRE>">>$ofile
ps axo pcpu,comm,pid,euser | sort -nr | head -n 10 >>$ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Running Services</H3><TD><PRE>">>$ofile
service --status-all  >>$ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>TCP Connections</H3><TD><PRE>">>$ofile
netstat -vnpta >>$ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>TCP Statistics</H3><TD><PRE>">>$ofile
netstat -st | head -n 27 >>$ofile

echo "<TR valign=\"top\"><TD colspan=\"2\" bgcolor=#D1EEEE><H2>Config Files</H2><TD><PRE>">>$ofile

#
# by default this includes most config files, comment out those you don't need for a shorter output
# config files are stripped of <tags> and replaced with ascii equivalent so that they will display in html
#

echo "Config Files...90%"

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>FSTAB Config</H3><TD><PRE>">>$ofile
cat /etc/fstab >> $ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Crontab Config</H3><TD><PRE>">>$ofile
/usr/bin/crontab -l | cat >> $ofile

echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>sysctl Config</H3><TD><PRE>">>$ofile
cat /etc/sysctl.conf >> $ofile

# Wild card added as interface names may vary greatly
echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Network Config</H3><TD><PRE>">>$ofile
cat /etc/sysconfig/network-scripts/ifcfg-e* >>$ofile 

# This need to be replaced with bootinfoscript
echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Grub Config</H3><TD><PRE>">>$ofile 
grep -v "^#" /etc/grub.conf | grep -v "^$" | sed 's/</\&#60;/' | sed 's/>/\&#62;/'>>$ofile

# commented out old modprobe 'grep' if your system s 'modeprobe.conf' is used and not '/etc/modprobe.d'
echo "<TR valign=\"top\"><TD bgcolor=#F0F0F0><H3>Modprobe Config</H3><TD><PRE>">>$ofile
#grep -v "^#" /etc/modprobe.conf | grep -v "^$" | sed 's/</\&#60;/' | sed 's/>/\&#62;/' >>$ofile
cat /sbin/modprobe -c >> $ofile

echo "</TABLE></BODY></HTML>">>$ofile

echo "Taking Important Files Backup"
mkdir -p /var/tmp/precheck
cp /etc/shadow /var/tmp/precheck/shadow.precheck.$(date +%d-%m-%Y)
cp /etc/passwd /var/tmp/precheck/passwd.precheck.$(date +%d-%m-%Y)
cp /etc/group /var/tmp/precheck/group.precheck.$(date +%d-%m-%Y)
cp /etc/fstab /var/tmp/precheck/fstab.precheck.$(date +%d-%m-%Y)
cp -rf /etc/sysconfig/network-scripts/ /var/tmp/precheck/network-scripts.$(date +%d-%m-%Y)
cp /etc/sysctl.conf /var/tmp/precheck/sysctl.conf.precheck.$(date +%d-%m-%Y)
cp /etc/grub.conf /var/tmp/precheck/grub.conf.precheck.$(date +%d-%m-%Y)
cp /etc/modprobe.conf /var/tmp/precheck/modprobe.conf.precheck.$(date +%d-%m-%Y)

echo "Finished...100%, open up the file in your favourite web browser"
exit 0