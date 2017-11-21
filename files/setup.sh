#!/bin/bash

mkdir -p ~/.ssh
cat /tmp/keys >> ~/.ssh/authorized_keys
yum -y update
yum install bind bind-utils -y

sudo cp -f /tmp/bind/named /etc/sysconfig/named
sudo cp -f /tmp/bind/named.conf /etc/named.conf
sudo cp /tmp/bind/zones.conf /etc/

mkdir /var/named/zones
cp /tmp/bind/*.zone /var/named/zones/

chmod 755 /var/named/zones
chmod 755 /etc/named.conf

firewall-cmd --permanent --add-service=dns
firewall-cmd --reload

systemctl enable named
systemctl start named
systemctl status named
