# smbmount
### Samba share mount in linux(ubuntu)

Usage: ./smbmount.sh OPTION..."

Samba Share Mount
This bash script helps you automatically mount a list of samba share. You must add your samba share address to mount-points file line by line.
Example of mount-points file: 
//192.168.1.1/share1
//192.168.1.1/share2

This shares address mount as /mnt/share1 , /mnt/share2

Options:
--help			Show this help.
-r, --restore		After changes of fstab by this bash script you can restore earlier version of that.
