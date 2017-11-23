#!/bin/bash
# This takes the DNS record info from the host_list.csv file and inputs into the appropriate zone file
# The zone files must exist for this to work (no checks in the script for appropriate zone files)

echo 'Make sure all your hostnames are RFC compliant'

INPUT=host_list.csv    # host_list.csv is the records we want to put into the zone files
ZONE_FILE_LOC=files/bind/    # relative directory of zone files

# Checks that host_list.csv exists, and if not, exists
if [ -f $INPUT ] ; then
  echo 'host_list.csv EXISTS, continuing...'
else
  echo 'host_list.csv DOES NOT EXIST, exiting...'
  exit 99
fi

# Sets $datetime to current date and time in order to update the serial in the zone files
datetime="$(date '+%Y%m%d%H%M%S')"

IFS=,
cur_fwd_zone=0
cur_rev_zone=0

{
  read line  # exclude the header line
  while read -r hostname ip_addr fwd_zone rev_zone comments
  do
    echo $i $hostname $ip_addr $fwd_zone $rev_zone $comments

    if [ -f "$ZONE_FILE_LOC$fwd_zone.zone" ] ; then
      if [ $cur_fwd_zone != $fwd_zone ] ; then
        echo "Exists: $ZONE_FILE_LOC$fwd_zone.zone"

        sed -i '' 's/.*serial.*/                    '$datetime'  ; serial (year)(m)(d)(h)(m)(s)/' $ZONE_FILE_LOC$fwd_zone.zone

      fi

      if !(grep -qw ^$hostname $ZONE_FILE_LOC$fwd_zone.zone) ; then
        len=$((19-${#hostname}))  # 20 = total hostname whitespace
        spaces=$(printf '%*s' "$len" | tr ' ' "#")  # gets proper amount of whitespace as char #

        echo "$hostname$spaces IN     A     $ip_addr" | tr '#' " " >> $ZONE_FILE_LOC$fwd_zone.zone
      fi

    else
      if [ $cur_fwd_zone != $fwd_zone ] ; then
        echo "Not exists: $ZONE_FILE_LOC$fwd_zone.zone"
      fi
    fi

    cur_fwd_zone=$fwd_zone

    if [ -f "$ZONE_FILE_LOC$rev_zone.zone" ] ; then
      if [ $cur_rev_zone != $rev_zone ] ; then
        echo "Exists: $ZONE_FILE_LOC$rev_zone.zone"

        sed -i '' 's/.*serial.*/                    '$datetime'  ; serial (year)(m)(d)(h)(m)(s)/' $ZONE_FILE_LOC$rev_zone.zone

      fi

      last_octet=$(echo $ip_addr | cut -d'.' -f4)

      if !(grep -qw ^$last_octet $ZONE_FILE_LOC$rev_zone.zone) ; then
        len=$((19-${#last_octet}))  # 20 = total hostname whitespace
        spaces=$(printf '%*s' "$len" | tr ' ' "#")  # gets proper amount of whitespace as char #

        echo "$last_octet$spaces IN     PTR     $hostname$fwd_zone." | tr '#' " " >> $ZONE_FILE_LOC$rev_zone.zone
      fi

    else
      if [ $cur_rev_zone != $rev_zone ] ; then
        echo "Not exists: $ZONE_FILE_LOC$rev_zone.zone"
      fi
    fi

    cur_rev_zone=$rev_zone



  done
} < $INPUT  # input file for loop
