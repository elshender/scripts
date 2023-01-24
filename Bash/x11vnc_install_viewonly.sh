#!/bin/bash

# ------------[27/7/2015]---------------#
#										#
#	Alex McPhee							#
#   Ubuntu-Quick-Install-Script			#
#	x11vnc - In  View Only				#
#	X11VNC Logfile Data-Cache SMB-Cred	#
#										#
#---------------------------------------#


# start message
/usr/bin/clear
echo 'Going to install x11vnc in view only mode, on your machine, here we go...' 2>>&1 1>~/x11vnc_install.log
echo '------------------------'

/bin/sleep 2

# tab width
tabs 4
/usr/bin/clear

# Run Updates
echo ''
echo '#------------------------------------#'
echo '#    Running Ubuntu System Update    #' 2>>&1 1>>~/x11vnc_install.log
echo '#------------------------------------#'

/bin/sleep 1
/usr/bin/apt-get -qqy update 2>>&1 1>>~/x11vnc_install.log
/usr/bin/apt-get -qqy upgrade 2>>&1 1>>~/x11vnc_install.log
/usr/bin/apt-get -qqy autoclean 2>>&1 1>>~/x11vnc_install.log

# tab width
tabs 4
/usr/bin/clear

# Install X11VNC
echo ''
echo '#------------------------------------#'
echo '#    Installing X11VNC Application   #' 2>>&1 1>>~/x11vnc_install.log
echo '#------------------------------------#'

/bin/sleep 1
/usr/bin/apt-get -qqy install x11vnc 2>>&1 1>>~/x11vnc_install.log
/usr/bin/clear

# Prepare Files And Folders
echo ''
echo '#------------------------------------#'
echo '#    Preparing Files & Folders	   #' 2>>&1 1>>~/x11vnc_install.log
echo '#------------------------------------#'

/bin/sleep 1

# Files to be Created
PATH1=~/.vnc/ 
PATH2=~/.authloc/
PATH3=~/.vncloc/
FILE=.smbcred

# Add file '/.vnc/' use by X11VNC as tmp data cache
if [ ! -d $PATH1 ]
	then
		echo $PATH1 'Could Not Find File'
		/bin/mkdir $PATH1 2>>&1 1>>~/x11vnc_install.log
		echo $PATH1 'Has Been Created'
fi

# Add file '/.authwob/' read only store of SMB credentials, used for .vnclock network share
if [ ! -d $PATH2 ]
	then
		echo $PATH2 'Could Not Find File'
		/bin/mkdir $PATH2 2>>&1 1>>~/x11vnc_install.log
		echo $PATH2 'Has Been Created'
		/usr/bin/touch $PATH2$FILE
fi
	
# Add file '/.vnclock/'	linked to network share with shared password
if [ ! -d $PATH3 ]
	then
		echo $PATH3 'Could Not Find File'
		/bin/mkdir $PATH3 2>>&1 1>>~/x11vnc_install.log
		echo $PATH3 'Has Been Created'
fi   

/usr/bin/clear
    echo ''
    echo '#------------------------------------#'
    echo '#    Prepare Folders: Complete       #' 2>>&1 1>>~/x11vnc_install.log
    echo '#------------------------------------#'
    /bin/sleep 2

# Network Share Credentials
    echo "username=administrator" >> $PATH2$FILE 2>>&1 1>>~/x11vnc_install.log
    echo "password=l1brary" >> $PATH2$FILE 2>>&1 1>>~/x11vnc_install.log   

    /usr/bin/clear
    echo ''
    echo '#------------------------------------#'
    echo '#      CIFS Credentials Saved        #' 2>>&1 1>>~/x11vnc_install.log
    echo '#------------------------------------#'
	/bin/sleep 2

# Changing '.smbcred' files permissions to 600. Read-Only
/usr/bin/clear
/bin/chmod 600 $PATH2$FILE 2>>&1 1>>~/x11vnc_install.log

    echo ''
    echo '#------------------------------------#'
    echo '#   .smbcred now 600 readonly        #' 2>>&1 1>>~/x11vnc_install.log
    echo '#------------------------------------#'
/bin/sleep 2
	
/usr/bin/clear
    echo ''
    echo '#------------------------------------#'
    echo '#       Installing Cifs-utils        #' 2>>&1 1>>~/x11vnc_install.log
    echo '#------------------------------------#'
/bin/sleep 2

# Install Cis-utils 
	/usr/bin/apt-get -qqy install cifs-utils 2>>&1 1>>~/x11vnc_install.log

/usr/bin/clear
    echo ''
    echo '#------------------------------------#'
    echo '#       Add /etc/fstab entrys        #' 2>>&1 1>>~/x11vnc_install.log
    echo '#------------------------------------#'
/bin/sleep 2

# Mount network share, Password store.	
#-----------------------------------#
	# Network File Path.
		echo -n "//192.168.1.2/Public/IT/CTSVNCPASS" >> /etc/fstab 
	# INSERT TAB
		echo -e -n "\t" >> /etc/fstab
	# Local File to Mouse Share to.
		echo -n "/home/wob/.vncloc" >> /etc/fstab 
	# INSERT TAB
		echo -e -n "\t" >> /etc/fstab
	# Common Internet File System chosen, can be set to 'nfs'	
		echo -n "cifs" >> /etc/fstab
	# INSERT TAB
		echo -e -n "\t" >> /etc/fstab  
	# Options	
		echo "credentials=/home/wob/.authwob/.smbcred,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm 0 0" >> /etc/fstab

/usr/bin/clear
    echo ''
    echo '#------------------------------------#'
    echo '#       /etc/fstab entrys added      #' 2>>&1 1>>~/x11vnc_install.log
    echo '#------------------------------------#'
/bin/sleep 2

/usr/bin/clear
    echo ''
    echo '#------------------------------------#'
    echo '#    Test Mounting, Network Share    #' 2>>&1 1>>~/x11vnc_install.log
    echo '#------------------------------------#'
/bin/sleep 3

# Mount share 
/bin/mount -a /home/wob/.vnclock 2>>&1 1>>~/x11vnc_install.log

sleep 1
	/usr/bin/clear
		echo ''
		echo '#------------------------------------#'
		echo '#    Checking if share is mounted    #' 2>>&1 1>>~/x11vnc_install.log
		echo '#------------------------------------#'
	/bin/sleep 3
	
if grep -qs '//192.168.1.2/Public/IT/CTSVNCPASS' /proc/mounts; then
	echo ''
    echo "It's mounted. Finishing Install Steps."
	echo ''
else
	echo ''
    echo "Share is NOT mounted. [Follow Manual Install]"
	echo ''
fi

/usr/bin/clear
		echo ''
		echo '#------------------------------------#'
		echo '#    Creating Auto-Mount Script      #' 2>>&1 1>>~/x11vnc_install.log
		echo '#------------------------------------#'
/bin/sleep 2

# NetworkManager init Script.	
# /etc/NetworkManager/dispatcher.d/nfs.sh
#------------------------------------------------#
# mount share once [if] eth(x) = up (connected).
#------------------------------------------------#	
	
	echo -e "#/bin/sh" > /etc/NetworkManager/dispatcher.d/nfs.sh
		echo '' >> /etc/NetworkManager/dispatcher.d/nfs.sh
		echo "###############################################################################
		" >> /etc/NetworkManager/dispatcher.d/nfs.sh
		echo "# Alex McPhee                                                                  #
		" >> /etc/NetworkManager/dispatcher.d/nfs.sh
		echo "# mount the drive till station reboots. we want a permanent mount.             #
		" >> /etc/NetworkManager/dispatcher.d/nfs.sh
		echo "# by adding a small script that mounts the share [if] eth(x) = up (connected). #
		" >> /etc/NetworkManager/dispatcher.d/nfs.sh
		echo "################################################################################
		" >> /etc/NetworkManager/dispatcher.d/nfs.sh
		echo '' >> /etc/NetworkManager/dispatcher.d/nfs.sh
		echo "if [ \"\$2\" = \"up\" ]" >> /etc/NetworkManager/dispatcher.d/nfs.sh
		echo "then" >> /etc/NetworkManager/dispatcher.d/nfs.sh
		echo "mount \"/home/wob/.vnclock\"" >> /etc/NetworkManager/dispatcher.d/nfs.sh
		echo "elif [ \"\$2\" = \"down\" ]" >> /etc/NetworkManager/dispatcher.d/nfs.sh
		echo "then" >> /etc/NetworkManager/dispatcher.d/nfs.sh
		echo "umount \"/home/wob/.vnclock\"" >> /etc/NetworkManager/dispatcher.d/nfs.sh
		echo "fi" >> /etc/NetworkManager/dispatcher.d/nfs.sh
		echo '' >> /etc/NetworkManager/dispatcher.d/nfs.sh
		echo "exit 0" >> /etc/NetworkManager/dispatcher.d/nfs.sh

/usr/bin/clear
		echo ''
		echo '#------------------------------------#'
		echo '#    Giving Executable Permisions    #' 2>>&1 1>>~/x11vnc_install.log
		echo '#------------------------------------#'
/bin/sleep 2

# Script Location 
nfs=/etc/NetworkManager/dispatcher.d/nfs.sh

# Executable permissions
/bin/chmod +x $nfs 2>>&1 1>>~/x11vnc_install.log

/usr/bin/clear
		echo ''
		echo '#------------------------------------#'
		echo '#    Checking File is Executable     #' 2>>&1 1>>~/x11vnc_install.log
		echo '#------------------------------------#'
/bin/sleep 2

# Check if newly created script is executable
if [[ -x "$nfs" ]]
then
/usr/bin/clear
		echo ''
		echo '#------------------------------------#'
		echo '#         File is Executable         #' 2>>&1 1>>~/x11vnc_install.log
		echo '#------------------------------------#'
		/bin/sleep 2
else
    echo "File '$nfs' is not executable or found"
/usr/bin/clear
		echo ''
		echo '#------------------------------------#'
		echo '#            Check Failed            #' 2>>&1 1>>~/x11vnc_install.log
		echo '#------------------------------------#'
fi

# VNC-Server Script
/usr/bin/clear
		echo ''
		echo '#------------------------------------#'
		echo '#      X11VNC Start-up Script        #' 2>>&1 1>>~/x11vnc_install.log
		echo '#------------------------------------#'
		/bin/sleep 2

# Make file '.unx11vnc_login.sh' and pass settings to it.		
x11start=/home/wob/.runx11vnc_login.sh

	echo -e "#/bin/sh" > $x11start
		echo '' >> $x11start
		echo "###############################################################################
		" >> $x11start
		echo "# Alex McPhee                                                                  #
		" >> $x11start
		echo "# Startup script so that X11VNC is automatically loaded at user login (with password settings and view only set)          #
		" >> $x11start
		echo "################################################################################
		" >> $x11start
		echo '' >> $x11start
		echo "/usr/bin/x11vnc -viewonly -shared -forever -rfbport 5900 -rfbauth ~/.vnclock/x11vnc.pass -o ~/.vnc/x11vnc.log -ncache -display :0 2> ~/.vnc/x11vnc_error.log" >> $x11start
		echo ''
		echo "exit 0"
		
/usr/bin/clear
		echo ''
		echo '#------------------------------------#'
		echo '#    Giving Executable Permisions    #' 2>>&1 1>>~/x11vnc_install.log
		echo '#------------------------------------#'
/bin/sleep 2

# Make script executable
/bin/chmod +x $x11start 2>>&1 1>>~/x11vnc_install.log

# Check if newly created script is executable
if [[ -x "$x11start" ]]
	then
		/usr/bin/clear
		echo ''
		echo '#------------------------------------#'
		echo '#         File is Executable         #' 2>>&1 1>>~/x11vnc_install.log
		echo '#------------------------------------#'
		/bin/sleep 2
	else
		echo "File '$x11start' is not executable or found"
fi

# End of install. print message

/usr/bin/clear
		echo ''
		echo '#------------------------------------#'
		echo '#         X11VNC Install Complete    #' 2>>&1 1>>~/x11vnc_install.log
		echo '#------------------------------------#'
		/bin/sleep 1
		echo ''
		echo '#------------------------------------#'
		echo 'Add to Start Applications the following:'
		echo '#------------------------------------#'
		/bin/sleep 1
		echo '#------------------------------------#'
		echo "x11start"
		echo '#------------------------------------#'
		
exit 0


