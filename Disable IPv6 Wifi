#!/bin/bash

# Detects all network hardware & creates services for all installed network hardware
networksetup -detectnewhardware

SAVEIFS=$IFS
IFS=$'\n'
for i in $(networksetup -listallnetworkservices | grep -v '*'); do
	networksetup -setv6off "$i"
done
IFS=$SAVEIFS
