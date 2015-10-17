#!/bin/bash
###########
# Author: Mohammad Reza Norouzi
# email: mohammad.r.noroozi@gmail.com
###########

echo "Samba Share Mount. Use --help for better description."

if [ "$1" == '--help' ]; then
	echo
	echo "Usage: ./smbmount.sh OPTION..."
	echo
	echo "Samba Share Mount"
	echo "This bash script helps you automatically mount a list of samba share. You must add your samba share address to mount-points file line by line."
	echo "Example of mount-points file: "
	echo "//192.168.1.1/share1"
	echo "//192.168.1.1/share2"
	echo
	echo "Options:"
	echo "--help			Show this help."
	echo "-r, --restore		After changes of fstab by this bash script you can restore earlier version of that."
	exit 0
fi

if [[ $UID != 0 ]]; then
	echo "bash: permission denied!"
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

if [[ "$1" == '--restore' || "$1" == '-r' ]]; then
	read -n1 -p "Are you sure you want to restore /etc/fstab to earlier version?(y/n) " answ
	echo
	if [ "$answ" == 'y' ]; then
		if [ -s "fstab~" ]; then
			cp fstab~ /etc/fstab
			if [ $? -eq 0 ]; then
				echo "fstab was restored successfully."
				exit 0
			else
				echo "Sorry, fstab restoration fail!"
				exit 33
			fi
		else
			echo "no any backup exist!"
			exit 32
		fi
	else
		exit 0
	fi
fi

if [ ! -s "mount-points" ]; then
	echo "The file mount-points doesn't exist or it's empty!"
	exit 16
fi

dpkg -l cifs-utils > /dev/null 2>&1 || apt-get install cifs-utils

# if [ $? -ne 0 ]; then
# 	echo "Package installation fail!"
# 	exit 2
# fi

echo
read -ep "linux username to access the mount directories: " lusername
echo
echo "pleas fill flowing network user info"
read -ep  "Username: " username
read -esp "Password: " netPass
echo
read -esp "Confirm password: " passConfirm
echo
if [ "$netPass" != "$passConfirm" ]; then
	echo password is not confirmed\!
	exit 4
fi
read -ep "Domain: " domain
echo


# make changes...


cp -f /etc/fstab fstab~ #create backup from /etc/fstab

echo username=$username > /root/smb.cred
echo password=$netPass >> /root/smb.cred
echo domain=$domain >> /root/smb.cred

chmod 740 /root/smb.cred

echo "######## samba share mount ########" >> /etc/fstab
cat mount-points | while read mntp; do
	if [[ ! "$a" =~ ^#.* ]]; then
		mntdir="/mnt/"$(echo $mntp|sed 's/.*\///g')
		mkdir -p $mntdir
		printf "%s\t%s\tcifs\tuid=%s,credentials=/root/smb.cred 0 0\n" $mntp $mntdir $lusername >> /etc/fstab
	fi
done
echo >> /etc/fstab

mount -a
if [ $? -eq 0 ]; then
	echo "All mount points was successfully added."
else
	echo "Operation fail!"
	exit 8
fi
