#!/bin/bash

# Set the hostname to the balena device name
balena_device_name=$(curl -s "$BALENA_SUPERVISOR_ADDRESS/v2/device/name?apikey=$BALENA_SUPERVISOR_API_KEY" | jq -r .deviceName)
curl -X PATCH --header "Content-Type:application/json" \
	--data "{\"network\": {\"hostname\": \"${balena_device_name}\"}}" \
	"$BALENA_SUPERVISOR_ADDRESS/v1/device/host-config?apikey=$BALENA_SUPERVISOR_API_KEY"

# Tell the container that DBUS should report to Host OS
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket

# Set rules for connection only through the public device URL
iptables -A INPUT -i resin-vpn -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -i resin-vpn -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j REJECT

cupsd -f