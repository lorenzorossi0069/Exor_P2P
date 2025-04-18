#!/bin/sh

source ./p2p_common.sh

ifconfig $IFACE 201.202.203.1  netmask 255.255.255.0

p2p_startWPAsupplicant

wpa_cli -i $IFACE p2p_group_add > /dev/null

# Trova la nuova interfaccia del gruppo (es. p2p-wlan0-0)
GROUP_IFACE=$(wpa_cli interface | grep p2p-wlan | grep -v interface)


PIN_P2P=$(wpa_cli -i $GROUP_IFACE wps_pin any)

# Trova interfaccia di gruppo client
GROUP_IFACE=$(wpa_cli interface | grep p2p-wlan | grep -v Selected)
echo "[GO] Connesso tramite: $GROUP_IFACE"

ifconfig $GROUP_IFACE 151.152.153.1

echo "[GO] Info gruppo: $GROUP_IFACE"
#wpa_cli -i $GROUP_IFACE status

echo "insert on other peer PIN $PIN_P2P"
echo



