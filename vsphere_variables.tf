variable "vsphere_password" {
    description = "The vsphere password"
}

variable "vsphere_username" {
    description = "Your vSphere username"
}

variable "vsphere_vcenter" {
    description = "vCenter IP or FQDN"
}

variable "vsphere_vm_name" {
    description = "The name of the VM to deploy"
}

variable "vsphere_os_hostname" {
    description = "The hostname of the VM to deploy"
}

variable "vsphere_vcpu" {
    description = "The # of vCPUs for the VM"
}

variable "vsphere_memory" {
    description = "The memory for the VM"
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

variable "vsphere_folder" {
    description = "The vsphere folder to put VM into"
}

variable "dns" {
    type = "list"
    description = "Local DNS servers"
}

variable "domain" {
    description = "Local domain suffix"
}

variable "ipv4_address_1" {
    description = "Static IPv4 address"
}

variable "ipv4_prefix_length_1" {
    description = "Prefix length of IPv4 address"
}

variable "ipv4_gateway_1" {
    description = "IPv4 gateway"
}
