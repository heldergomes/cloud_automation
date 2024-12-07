terraform {
  required_providers {
    mgc = {
      source  = "magalucloud/mgc"
    }
  }
}

provider "mgc" {
    api_key = ""
    region  = "br-ne1"
}

resource "mgc_network_security_groups" "sg_1" {
  name                  = "postgres-sg"
  description           = "postgres-sg"
  disable_default_rules = false
}

resource "mgc_network_security_groups_rules" "allow_ssh_i" {
  description      = "Allow incoming SSH traffic"
  direction        = "ingress"
  ethertype        = "IPv4"
  port_range_max   = 22
  port_range_min   = 22
  protocol         = "tcp"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = mgc_network_security_groups.sg_1.id
}
resource "mgc_network_security_groups_rules" "allow_ssh_o" {
  description      = "Allow incoming SSH traffic"
  direction        = "egress"
  ethertype        = "IPv4"
  port_range_max   = 22
  port_range_min   = 22
  protocol         = "tcp"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = mgc_network_security_groups.sg_1.id
}

resource "mgc_network_security_groups_rules" "allow_postgres_i" {
  description      = "Allow incoming SSH traffic"
  direction        = "ingress"
  ethertype        = "IPv4"
  port_range_max   = 5432
  port_range_min   = 5432
  protocol         = "tcp"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = mgc_network_security_groups.sg_1.id
}
resource "mgc_network_security_groups_rules" "allow_postgres_o" {
  description      = "Allow incoming SSH traffic"
  direction        = "egress"
  ethertype        = "IPv4"
  port_range_max   = 5432
  port_range_min   = 5432
  protocol         = "tcp"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = mgc_network_security_groups.sg_1.id
}

resource "mgc_virtual_machine_instances" "vm-tomato" {
    name     = "vm-test-1"
    machine_type = {
        name = "BV2-8-20"
    }
    image = {
        name = "cloud-ubuntu-20.04 LTS"
    }
    network = {
        associate_public_ip = true
        delete_public_ip    = true
        interface = {
          security_groups = [{ id = mgc_network_security_groups.sg_1.id }]
        }
    }

    ssh_key_name = "tomate-ssh"
}

resource "mgc_block_storage_volumes" "bs-tomato" {
    name = "bs-test-1"
    size = 50
    type = {
        name = "cloud_nvme1k"
    }
}

resource "mgc_block_storage_volume_attachment" "attach-tomato" {
    block_storage_id = mgc_block_storage_volumes.bs-tomato.id
    virtual_machine_id = mgc_virtual_machine_instances.vm-tomato.id
}

output "vm_instances_id" {
  value = mgc_virtual_machine_instances.vm-tomato.id
}
output "vm_instances_ipv4" {
  value = mgc_virtual_machine_instances.vm-tomato.network.public_address
}
