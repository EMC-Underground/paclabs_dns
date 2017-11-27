# Lab BIND DNS & Kea DHCP server on CentOS 7

Builds a server on a CentOS 7 template using Terraform.
Installs and configures BIND DNS and Kea DHCP on the server.

To build you can run 'make' which will do the following:
> ./gen_zones.sh - Copies BIND files to ./files/bind/ and create new zone files
> ./gen_hosts.sh - Appends A & PTR records from host_list.csv into zone files
> terraform init
> terraform apply

## BIND DNS Server

Creates zone files defined in gen_zones.vars and appends records defined in host_lists.csv.

User-defined variable files:
- "gen_zones.vars" - Defines primary and secondary zones to create, used by ./gen_zones.sh
- "terraform.tfvars" - Terraform environment variables
- "host_list.csv" (optional) - List of A & PTR records to append to zone files
- Also edit "main.tf" to define the VM

Examples of the above are provided (*.example)

## Kea DHCP Server

Working on this piece
