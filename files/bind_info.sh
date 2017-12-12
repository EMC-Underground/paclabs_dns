#!/bin/bash

rndc status
systemctl status named
echo
echo "BIND config file: /etc/named.conf"
echo "Zone config file: /etc/zones.conf"
echo "Zone files are in /var/named/zones/"
echo
echo "Logs are in: /var/log/messages"
echo
echo "You can use the update_hosts.sh script to update using a host_list.csv which will:"
echo '1. Freeze the zone files: "rndc freeze"'
echo '2. Update all the zone files with new entries as needed'
echo '3. Reload the zone files: "rndc reload"'
echo '4. Thaw the zone files: "rndc thaw"'
echo
echo "Note: You should update the files when there's a low chance of a new"
echo "DDNS entry being created."
echo
