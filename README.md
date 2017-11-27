# Lab BIND DNS server on CentOS 7

Builds a VM on a CentOS 7 template using Terraform.
Installs and configures BIND DNS on the server.

Execute 'make' to do the following:
1. ./gen_zones.sh - Copies BIND files to ./files/bind/ and create new zone files from a template
2. ./gen_hosts.sh - Appends A & PTR records from host_list.csv into zone files
3. terraform init
4. terraform apply

User-defined variable files:
- "gen_zones.vars" - Define the primary and secondary zones to create, used by ./gen_zones.sh
- "terraform.tfvars" - Terraform environment variables
- "host_list.csv" (optional) - List of A & PTR records to append to zone files
- Also edit "main.tf" to define the VM

Examples of the variable files are provided (*.example)
