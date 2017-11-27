#!/bin/bash
# Requires gen_zones.vars
# This will create base zone files from the template in ./bind_templates/

source gen_zones.vars
datetime="$(date '+%Y%m%d%H')"  # Used for SERIAL value in zone files

echo "Lab: $LAB"
echo "Authoritative DNS server for Primary zones (SOA server): $SOA_DNS_SERVER"
echo "SOA email address: $SOA_EMAIL_ADDRESS"
echo "Secondary DNS server (authoritative for slave zones): $SECONDARY_DNS_SERVER"

if [ $REVERSE_PRIMARY_WITH_SLAVE = "true" ] ; then
  echo "Reverse primary with slave set to TRUE"
  echo "Swapping Primary and Slave zones for this build"

  temp_swap=("${PRIMARY_FORWARD_ZONES[@]}")
  PRIMARY_FORWARD_ZONES=("${SLAVE_FORWARD_ZONES[@]}")
  SLAVE_FORWARD_ZONES=("${temp_swap[@]}")

  temp_swap=("${PRIMARY_REVERSE_ZONES[@]}")
  PRIMARY_REVERSE_ZONES=("${SLAVE_REVERSE_ZONES[@]}")
  SLAVE_REVERSE_ZONES=("${temp_swap[@]}")
else
  echo "Reverse primary with slave: $REVERSE_PRIMARY_WITH_SLAVE"
fi

cp bind_templates/named.conf files/bind/
cp bind_templates/zones.conf files/bind/
cp bind_templates/named files/bind/

# There are four loops that go through the primary forward zones, primary reverse zones
# Secondary forward zones, and secondary reverse zones defined in the .vars file
# Within each loop it will copy either the forward or reverse zone template to a new zone file
# and then replace each variable within the template with appropriate values
# The Primary zones will have (type master) while the Slave zones (type slave) with  master servers

for i in "${PRIMARY_FORWARD_ZONES[@]}"
do
  cp bind_templates/forward_zone.template files/bind/$i.zone
  sed -i 's/#FORWARD_ZONE_NAME#/'$i'/' files/bind/$i.zone
  sed -i 's/#SOA_DNS_SERVER#/'$SOA_DNS_SERVER'/' files/bind/$i.zone
  sed -i 's/#SOA_EMAIL_ADDRESS#/'$SOA_EMAIL_ADDRESS'/' files/bind/$i.zone
  sed -i 's/#SECONDARY_DNS_SERVER#/'$SECONDARY_DNS_SERVER'/' files/bind/$i.zone
  sed -i 's/#SERIAL#/'$datetime'/' files/bind/$i.zone

  cp bind_templates/zones.example files/bind/
  sed -i 's/#PROPER_ZONE_NAME#/'$i'/' files/bind/zones.example
  sed -i 's/#ZONE_TYPE#/master/' files/bind/zones.example
  sed -i 's/#ZONE_NAME#/'$i'/' files/bind/zones.example
  sed -i '/#MASTERS#/d' files/bind/zones.example

  cat files/bind/zones.example >> files/bind/zones.conf
  echo "Created primary forward zone: $i"
done

for i in "${PRIMARY_REVERSE_ZONES[@]}"
do
  PROPER_REVERSE_OCTETS=$(echo $i | awk -F. '{print $3 "." $2 "." $1}')

  cp bind_templates/reverse_zone.template files/bind/$i.zone

  sed -i 's/#REVERSE_ZONE_NETWORK#/'$i'/' files/bind/$i.zone
  sed -i 's/#PROPER_REVERSE_OCTETS#/'$PROPER_REVERSE_OCTETS'/' files/bind/$i.zone
  sed -i 's/#SOA_DNS_SERVER#/'$SOA_DNS_SERVER'/' files/bind/$i.zone
  sed -i 's/#SOA_EMAIL_ADDRESS#/'$SOA_EMAIL_ADDRESS'/' files/bind/$i.zone
  sed -i 's/#SECONDARY_DNS_SERVER#/'$SECONDARY_DNS_SERVER'/' files/bind/$i.zone
  sed -i 's/#SERIAL#/'$datetime'/' files/bind/$i.zone

  cp bind_templates/zones.example files/bind/
  sed -i 's/#PROPER_ZONE_NAME#/'$PROPER_REVERSE_OCTETS'.in-addr.arpa/' files/bind/zones.example
  sed -i 's/#ZONE_TYPE#/master/' files/bind/zones.example
  sed -i 's/#ZONE_NAME#/'$i'/' files/bind/zones.example
  sed -i '/#MASTERS#/d' files/bind/zones.example

  cat files/bind/zones.example >> files/bind/zones.conf
  echo "Created primary reverse zone: $i ($PROPER_REVERSE_OCTETS.in-addr.arpa)"
done

for i in "${SLAVE_FORWARD_ZONES[@]}"
do
    cp bind_templates/forward_zone.template files/bind/$i.zone
    sed -i 's/#FORWARD_ZONE_NAME#/'$i'/' files/bind/$i.zone
    sed -i 's/#SOA_DNS_SERVER#/'$SECONDARY_DNS_SERVER'/' files/bind/$i.zone
    sed -i 's/#SOA_EMAIL_ADDRESS#/'$SOA_EMAIL_ADDRESS'/' files/bind/$i.zone
    sed -i 's/#SECONDARY_DNS_SERVER#/'$SOA_DNS_SERVER'/' files/bind/$i.zone
    sed -i 's/#SERIAL#/'$datetime'/' files/bind/$i.zone

    cp bind_templates/zones.example files/bind/
    sed -i 's/#PROPER_ZONE_NAME#/'$i'/' files/bind/zones.example
    sed -i 's/#ZONE_TYPE#/slave/' files/bind/zones.example
    sed -i 's/#ZONE_NAME#/'$i'/' files/bind/zones.example
    sed -i 's/#MASTERS#/'$SECONDARY_DNS_IP_ADDRESS'/' files/bind/zones.example

    cat files/bind/zones.example >> files/bind/zones.conf
    echo "Created slave forward zone: $i"
done

for i in "${SLAVE_REVERSE_ZONES[@]}"
do
  PROPER_REVERSE_OCTETS=$(echo $i | awk -F. '{print $3 "." $2 "." $1}')

  cp bind_templates/reverse_zone.template files/bind/$i.zone

  sed -i 's/#REVERSE_ZONE_NETWORK#/'$i'/' files/bind/$i.zone
  sed -i 's/#PROPER_REVERSE_OCTETS#/'$PROPER_REVERSE_OCTETS'/' files/bind/$i.zone
  sed -i 's/#SOA_DNS_SERVER#/'$SECONDARY_DNS_SERVER'/' files/bind/$i.zone
  sed -i 's/#SOA_EMAIL_ADDRESS#/'$SOA_EMAIL_ADDRESS'/' files/bind/$i.zone
  sed -i 's/#SECONDARY_DNS_SERVER#/'$SOA_DNS_SERVER'/' files/bind/$i.zone
  sed -i 's/#SERIAL#/'$datetime'/' files/bind/$i.zone

  cp bind_templates/zones.example files/bind/
  sed -i 's/#PROPER_ZONE_NAME#/'$PROPER_REVERSE_OCTETS'.in-addr.arpa/' files/bind/zones.example
  sed -i 's/#ZONE_TYPE#/slave/' files/bind/zones.example
  sed -i 's/#ZONE_NAME#/'$i'/' files/bind/zones.example
  sed -i 's/#MASTERS#/'$SECONDARY_DNS_IP_ADDRESS'/' files/bind/zones.example

  cat files/bind/zones.example >> files/bind/zones.conf
  echo "Created secondary reverse zone: $i ($PROPER_REVERSE_OCTETS.in-addr.arpa)"
done
