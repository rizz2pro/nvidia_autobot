#!/bin/bash

# This will check if your IP has been banned and are being redirected to facebook.com/canadacomputers 
# If it does, it will kill your VPN and use the next config file under $base_dir/vpnconfigs and reconnect with new ip

# Check if already running
pid=$(echo $$)
if ps aux | grep -v sudo | grep -v $pid | grep -v vpnswitch.log | grep [v]pnswitch
then
        echo "Already running, exiting"
        exit
fi

# Figure out base dir and source global vars
base_dir=$(dirname $0)
source  $base_dir/vars.txt

while true; do
# I set an entry in my hosts file: 127.0.0.1 facebook.com - when we are redirected, the request fails hard and curl exits with an error code
wget -qO /dev/null https://www.canadacomputers.com
	RETVAL=$?
	echo retval is $RETVAL
	# If curl failed, kill the running VPN process
	if [ $RETVAL -ne 1 ]; then
		for ps in $(ps aux | grep [o]penvpn | awk '{ print $2 }'); do
			kill $ps
		done
		# Move the config we're using to the graveyard - they are going to be unbanned in 24 hours
		if ! [ -z $src ]; then
			mv $base_dir/vpnconfigs/$src $base_dir/vpnconfigs_blocked
		fi
		# Connect with the next VPN profile in the list
		src=$(ls -1 $base_dir/vpnconfigs | head -1)
		cp $base_dir/vpnconfigs/$src $base_dir/vpnconfigs/master.conf
		/usr/sbin/openvpn --config $base_dir/vpnconfigs/master.conf --daemon --auth-user-pass $base_dir/configs/vpn_cred.conf
		sleep 6
		myip=$(curl ifconfig.co)
		echo "VPN Changed, new IP is $myip"
	fi
	sleep 10
done

