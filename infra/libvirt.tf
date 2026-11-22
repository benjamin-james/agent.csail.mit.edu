provider "libvirt" {
  uri = coalesce(
    var.libvirt_uri,
    "qemu+ssh://${var.libvirt_ssh_user}@${var.libvirt_hypervisor}/system"
  )
}

resource "libvirt_volume" "base" {
  name   = "agent-runner-base.qcow2"
  pool   = "default"
  source = var.libvirt_base_image_url
  format = "qcow2"
}

resource "libvirt_volume" "runner" {
  for_each = var.libvirt_runners

  name           = "${each.value.hostname}.qcow2"
  pool           = "default"
  format         = "qcow2"
  base_volume_id = libvirt_volume.base.id
  size           = each.value.disk_gb * 1024 * 1024 * 1024
}

resource "libvirt_cloudinit_disk" "runner" {
  for_each = var.libvirt_runners

  name = "${each.value.hostname}-cloudinit.iso"
  pool = "default"

  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    hostname            = each.value.hostname
    ssh_authorized_keys = var.ssh_authorized_keys
  })

  network_config = <<-EOT
    version: 2
    ethernets:
      ens3:
        addresses:
          - ${each.value.ip}/24
        routes:
          - to: default
            via: 192.168.122.1
        nameservers:
          addresses:
            - 192.168.122.1
            - 8.8.8.8
  EOT
}

resource "libvirt_domain" "runner" {
  for_each = var.libvirt_runners

  name      = each.value.hostname
  memory    = each.value.memory_mb
  vcpu      = each.value.vcpu
  autostart = true

  # expose the host CPU model/features (SSE4.2, AVX, ... x86-64-v2/v3) instead
  # of qemu's conservative default, which lacks features some binaries require
  cpu {
    mode = "host-passthrough"
  }

  cloudinit = libvirt_cloudinit_disk.runner[each.key].id

  network_interface {
    network_name = "default"
  }

  disk {
    volume_id = libvirt_volume.runner[each.key].id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}

output "libvirt_runner_hosts" {
  value = {
    for k, r in var.libvirt_runners : k => {
      hostname = r.hostname
      ip       = r.ip
    }
  }
}
