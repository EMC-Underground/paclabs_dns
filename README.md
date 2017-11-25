Lab BIND DNS server on CentOS 7

Builds a BIND DNS server on a CentOS 7 template using Terraform. Creates zone files defined in gen_zones.vars and appends records defined in host_lists.csv.

User-defined variable files:
- "gen_zones.vars" - Defines primary and secondary zones to create, used by ./gen_zones.sh
- "terraform.tfvars" - Terraform environment variables
- "host_list.csv" (optional) - List of A & PTR records to append to zone files

Examples of the above are provided (*.example)

- Also edit main.tf to define your VM

To build you can run 'make' which will do the following:
1. ./gen_zones.sh - Copies BIND files to ./files/bind/ and create new zone files
2. ./gen_hosts.sh - Appends A & PTR records from host_list.csv into zone files
3. terraform init
4. terraform apply
