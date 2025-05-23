#!/bin/sh

UNSPECIFIED=NN

if (($# < 1)) ; then
	DEV_NAME=$UNSPECIFIED
	echo "searching for peers"
else
	DEV_NAME=$1
	echo "searching for peer with device_name=$DEV_NAME"
fi

source ./p2p_common.sh

ifconfig $IFACE 201.202.203.2  netmask 255.255.255.0

p2p_startWPAsupplicant

# p2p_find can be called just once, 
# but for industrial/noisy environment it is good to recall it cyclically
# to keep scan alive (when RESCAN >= 5)

PEER_FOUND=""
RESCAN=5

# p2p_find and p2p_peer 
while [ -z $PEER_FOUND ] ; do
	if [ $RESCAN -ge 5 ] ; then
		#time to time restart scan (p2p_find) to help in noisy environments
		wpa_cli -i $IFACE p2p_find
		RESCAN=0
	fi
	RESCAN=$(($RESCAN+1))
	
	PEERS=$(wpa_cli -i $IFACE p2p_peers)
	
	echo "list of found peers:"
	
	for PEER in $PEERS ; do
		INFO=$(wpa_cli -i $IFACE p2p_peer $PEER | grep "$DEV_NAME")
		
		if [[ $INFO =~ P2P-AW64 ]] || [[ $DEV_NAME == $UNSPECIFIED ]] ; then
			PEER_FOUND=$PEER
			INFO_DEV_NAME=$(wpa_cli -i $IFACE p2p_peer $PEER | grep "device_name")
		fi
		echo "$INFO_DEV_NAME $PEERS"
		
	done
	echo 
	
	sleep 2
done

# p2p_connect (returning PIN for peer)
echo "DBG wpa_cli -i $IFACE p2p_connect $PEER_FOUND $P2P_PEER_PIN join"
PIN_C= $(wpa_cli -i $IFACE p2p_connect $PEER_FOUND pin join)

echo  "Insert on other peer the PIN: $PIN_C"
echo


GROUP_IFACE=''
while [ -z "$GROUP_IFACE" ] ; do
	# Trova interfaccia di gruppo client
	GROUP_IFACE=$(wpa_cli -i $IFACE interface | grep p2p-wlan | grep -v Selected)
	echo "waiting for connection..."
	sleep 2
done

ifconfig $GROUP_IFACE 151.152.153.2

#echo "[CLIENT] Group Infos:
#wpa_cli -i $GROUP_IFACE status

sleep 3
echo
echo "Press enter to test some pings" ; read doPing
ping -c 3  151.152.153.1

