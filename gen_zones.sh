#!/bin/bash
# Requires gen_zones.vars
# Creates zone files and zones.conf files from templates in ./bind_templates/

source gen_zones.vars
datetime="$(date '+%Y%m%d%H')"  # Used for SERIAL value in zone files

echo "Lab: $LAB"
echo "Authoritative DNS server for Primary zones (SOA server): $SOA_DNS_SERVER"
echo "SOA email address: $SOA_EMAIL_ADDRESS"
echo "Secondary DNS server (authoritative for slave zones): $SECONDARY_DNS_SERVER"

# If $REVERSE_PRIMARY_WITH_SLAVE is set to true it will reverse the
# PRIMARY and SLAVE zone variables. This allows you to build a second server
# that has the PRIMARY and SLAVE zones swapped.
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
echo

# Copies Bind configuration files to folder for transfer.
# The zones.conf will be concatenated with additional definitions.
mkdir files/bind
cp bind_templates/named.conf files/bind/
cp bind_templates/named files/bind/
cp bind_templates/zones.conf files/bind/

# Function to edit a created zone file with appropriate values.
# $1 = zone name = filename of the zone file
# $2 = forward zone name or reverse zone inverse address
# $3 = "master" or "slave"
edit_zone_files () {
  sed -i "s/#ZONE_NAME#/$2/" files/bind/$1.zone
  sed -i "s/#SERIAL#/$datetime/" files/bind/$1.zone


  if [ $3 = "master" ] ; then
    sed -i "s/#SOA_DNS_SERVER#/$SOA_DNS_SERVER/" files/bind/$1.zone
    sed -i "s/#SOA_EMAIL_ADDRESS#/$SOA_EMAIL_ADDRESS/" files/bind/$1.zone
    sed -i "s/#SECONDARY_DNS_SERVER#/$SECONDARY_DNS_SERVER/" files/bind/$1.zone
  elif [ $3 = "slave" ] ; then
    sed -i "s/#SOA_DNS_SERVER#/$SECONDARY_DNS_SERVER/" files/bind/$1.zone
    sed -i "s/#SOA_EMAIL_ADDRESS#/$SECONDARY_EMAIL_ADDRESS/" files/bind/$1.zone
    sed -i "s/#SECONDARY_DNS_SERVER#/$SOA_DNS_SERVER/" files/bind/$1.zone
  fi

}

# Function to create a zone definition and appends to zones.conf
# $1 = zone name or reverse zone inverse address
# $2 = zone name = filename of the zone file
# $3 = "master" or "slave"
edit_zones_conf () {
  sed -i "s/#PROPER_ZONE_NAME#/$1/" files/bind/zones_conf.template
  sed -i "s/#ZONE_NAME#/$2/" files/bind/zones_conf.template
  sed -i "s/#ZONE_TYPE#/$3/" files/bind/zones_conf.template

  if [ $3 = "master" ] ; then
    sed -i "s/#EXTRA_OPTIONS#/allow-update { $DDNS_SERVERS };/" files/bind/zones_conf.template
    sed -i '/#MASTERS#/d' files/bind/zones_conf.template
  elif  [ $3 = "slave" ] ; then
    sed -i 's/#EXTRA_OPTIONS#/masterfile-format text;/' files/bind/zones_conf.template
    sed -i 's/#MASTERS#/'$SECONDARY_DNS_IP_ADDRESS'/' files/bind/zones_conf.template
  fi

  cat files/bind/zones_conf.template >> files/bind/zones.conf
}

# There are four loops that go through primary/slave forward/reverse zones
# that are defined in the gen_zones.vars file.
# For each zone it will create a zone file and an entry in zones.conf.
for i in "${PRIMARY_FORWARD_ZONES[@]}"
do
  cp bind_templates/zone_file.template files/bind/$i.zone
  edit_zone_files $i $i "master"
  echo -e "\n; A Records" >> files/bind/$i.zone

  cp bind_templates/zones_conf.template files/bind/
  edit_zones_conf $i $i "master"
  echo "Created primary forward zone: $i"
done

for i in "${PRIMARY_REVERSE_ZONES[@]}"
do
  INV_ADDRESS=$(echo $i | awk -F. '{print $3 "." $2 "." $1}')

  cp bind_templates/zone_file.template files/bind/$i.zone
  edit_zone_files $i $INV_ADDRESS.in-addr.arpa "master"
  echo -e "\n; PTR Records" >> files/bind/$i.zone

  cp bind_templates/zones_conf.template files/bind/
  edit_zones_conf $INV_ADDRESS.in-addr.arpa $i "master"
  echo "Created primary reverse zone: $i ($INV_ADDRESS.in-addr.arpa)"
done

for i in "${SLAVE_FORWARD_ZONES[@]}"
do
    cp bind_templates/zone_file.template files/bind/$i.zone
    edit_zone_files $i $i "slave"
    echo -e "\n; A Records" >> files/bind/$i.zone

    cp bind_templates/zones_conf.template files/bind/
    edit_zones_conf $i $i "slave"
    echo "Created slave forward zone: $i"
done

for i in "${SLAVE_REVERSE_ZONES[@]}"
do
  INV_ADDRESS=$(echo $i | awk -F. '{print $3 "." $2 "." $1}')

  cp bind_templates/zone_file.template files/bind/$i.zone
  edit_zone_files $i $INV_ADDRESS.in-addr.arpa "slave"
  echo -e "\n; PTR Records" >> files/bind/$i.zone

  cp bind_templates/zones_conf.template files/bind/
  edit_zones_conf $INV_ADDRESS.in-addr.arpa $i "slave"
  echo "Created slave reverse zone: $i ($INV_ADDRESS.in-addr.arpa)"
done

rm files/bind/zones_conf.template
