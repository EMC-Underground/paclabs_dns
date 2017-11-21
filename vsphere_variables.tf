variable "vsphere_password" {
    description = "The vsphere password"
}

variable "vsphere_username" {
    description = "Your vSphere username"
}

variable "vsphere_vcenter" {
    description = "vCenter IP or FQDN"
}

variable "vsphere_datastore" {
    description = "The vsphere datastore to deploy on"
}

variable "vsphere_datacenter" {
    description = "The vsphere datacenter to deploy on"
}

variable "vsphere_cluster" {
    description = "The vsphere cluster to deploy on"
}

variable "vsphere_template" {
    description = "The VM template to use"
}

variable "vsphere_port_group_1" {
    description = "The vsphere port group the VM will use"
}

variable "vsphere_port_group_2" {
    description = "The vSphere port group used for data if necessary (Optional)"
}

variable "vsphere_folder" {
    description = "The vsphere folder to put VM into"
}

variable "dns" {
    description = "Local DNS"
}

variable "domain" {
    description = "Local domain suffix"
}

variable "ipv4_address" {
    description = "Static IPv4 address"
}

variable "ipv4_prefix_length" {
    description = "Prefix length of IPv4 address"
}

variable "ipv4_gateway" {
    description = "IPv4 gateway"
}
