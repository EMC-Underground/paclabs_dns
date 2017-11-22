# paclabs_dns
Lab BIND DNS server on CentOS 7

Zone definition files are located in files/bind/

You can create a host_list.csv (example given) of records you want to populate
into the zone definition files - make sure to be RFC compliant (e.g. no _'s)

There is a script "gen_zones.sh" that will append the zone definition files
with the entries from host_list.csv to the proper zone definition files

You can do everything at once by placing host_list.csv into the make
folder and running "make gen_zones" which will run "gen_zones.sh" and then
proceed with creating the DNS server

Or just run "make" to create the DNS server only

Or:

terraform init
terraform apply
