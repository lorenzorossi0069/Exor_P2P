#!/bin/sh

source ./p2p_common.sh

ifconfig $IFACE 201.202.203.2  netmask 255.255.255.0

p2p_startWPAsupplicant

# p2p_find can be called just once, 
# but for industrial/noisy environment it is good to recall it cyclically
# to keep scan alive (when RESCAN >= 5)

PEERS=""
RESCAN=5

while [ -z "$PEERS" ] ; do
	if [ $RESCAN -ge 5 ] ; then
		#keep scan alive in noisy environment
		wpa_cli -i $IFACE p2p_find
		RESCAN=0
	fi
	RESCAN=$(($RESCAN+1))
	echo RESCAN = $RESCAN
	sleep 2
	
	PEERS=$(wpa_cli -i $IFACE p2p_peers)
	echo "finding peers"
	sleep 2
done

PEER=$(echo "$PEERS" | head -n 1)
echo "[CLIENT] Peer found: $PEER"
#wpa_cli -i $IFACE p2p_peer "$PEER"

echo -n "Insert PIN: "; read P2P_PEER_PIN
echo

#launch connection request to GO
#use join if you want to connecto to an already estabilished GO (no negotiation)
wpa_cli -i $IFACE p2p_connect $PEER $P2P_PEER_PIN join

#wait connection
GROUP_IFACE=''
while [ -z "$GROUP_IFACE" ] ; do
	# Trova interfaccia di gruppo client
	GROUP_IFACE=$(wpa_cli -i $IFACE interface | grep p2p-wlan | grep -v Selected)
	echo "waiting for connection..."
	sleep 2
done

echo "[CLIENT] Connesso tramite: $GROUP_IFACE"



ifconfig $GROUP_IFACE 151.152.153.2

#echo "[CLIENT] Info gruppo:
#wpa_cli -i $GROUP_IFACE status

echo
echo "test 3 pings"
ping -c 3  151.152.153.1

