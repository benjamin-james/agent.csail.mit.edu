terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.4"
    }
  }
}

provider "openstack" {
  cloud = "csail"
}

data "openstack_networking_network_v2" "inet" {
  name = "inet"
}

resource "openstack_networking_secgroup_v2" "hello" {
  name        = "hello-caddy"
  description = "Minimal HTTPS hello-world server"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.admin_cidr
  security_group_id = openstack_networking_secgroup_v2.hello.id
}

resource "openstack_networking_secgroup_rule_v2" "http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.hello.id
}

resource "openstack_networking_secgroup_rule_v2" "https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.hello.id
}

resource "openstack_compute_instance_v2" "hello" {
  name            = "hello-caddy"
  image_id        = var.image_id
  flavor_name     = var.flavor_name
  security_groups = [openstack_networking_secgroup_v2.hello.name]

  network {
    uuid        = data.openstack_networking_network_v2.inet.id
    fixed_ip_v4 = var.fixed_ip
  }

  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    hostname = var.hostname
    ssh_authorized_keys = var.ssh_authorized_keys
  })
}


resource "openstack_blockstorage_volume_v3" "data" {
  name        = "hello-caddy-data"
  size        = var.data_volume_size_gb
  volume_type = "production"

  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_compute_volume_attach_v2" "data" {
  instance_id = openstack_compute_instance_v2.hello.id
  volume_id   = openstack_blockstorage_volume_v3.data.id
}

output "url" {
  value = "https://${var.hostname}"
}

output "ssh" {
  value = "ssh ubuntu@${var.hostname}"
}
