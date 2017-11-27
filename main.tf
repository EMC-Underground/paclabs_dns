provider "vsphere" {
  user           = "${var.vsphere_username}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_vcenter}"

  # if you have a self-signed cert
  allow_unverified_ssl = true
}

resource "vsphere_virtual_machine" "norcaldns1" {
  name   = "${var.vsphere_vm_name}"
  hostname = "${var.vsphere_os_hostname}"
  domain = "${var.domain}"
  datacenter = "${var.vsphere_datacenter}"
  folder = "${var.vsphere_folder}"
  dns_servers = ["${var.dns}"]
  cluster = "${var.vsphere_cluster}"
  time_zone = "America/Los_Angeles"
  vcpu   = "${var.vsphere_vcpu}"
  memory = "${var.vsphere_memory}"

  network_interface {
    label = "${var.vsphere_port_group_1}"
    ipv4_address = "${var.ipv4_address_1}"
    ipv4_prefix_length = "${var.ipv4_prefix_length_1}"
    ipv4_gateway = "${var.ipv4_gateway_1}"
  }

  disk {
    template = "${var.vsphere_template}"
    type = "thin"
    datastore = "${var.vsphere_datastore}"
  }

  provisioner "file" {
    source = "files/"
    destination = "/tmp"

    connection {
      type = "ssh"
      user = "root"
      password = "password"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/setup.sh",
      "sudo /tmp/setup.sh",
    ]

    connection {
      type = "ssh"
      user = "root"
      password = "password"
    }
  }
}

/*
output "master_public_ip" {
  value = "${vsphere_virtual_norcaldns1_master.network_interface.0.ipv4_address}"
}
*/
