variable "hostname" {
  type = string
}

variable "fixed_ip" {
  type = string
}

variable "image_id" {
  type = string
}

variable "flavor_name" {
  type    = string
  default = "ups.2c2g"
}

variable "admin_cidr" {
  type = string
}

variable "data_volume_size_gb" {
  type    = number
  default = 20
}

variable "ssh_authorized_keys" {
  description = "Public SSH keys allowed to log into the VM."
  type        = list(string)
}

variable "runners" {
  type = map(object({
    hostname  = string
    fixed_ip  = string
    flavor    = string
    data_gb   = optional(number, 0)
  }))
}

variable "libvirt_hypervisor" {
  description = "libvirt hypervisor host running the VMs."
  type        = string
  default     = "kellislab1.csail.mit.edu"
}

variable "libvirt_ssh_user" {
  description = "SSH user Terraform uses to reach the libvirt daemon on the hypervisor."
  type        = string
  default     = "benjames"
}

variable "libvirt_base_image_url" {
  description = "Cloud image the runner VMs are cloned from."
  type        = string
  default     = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2"
}

variable "libvirt_runners" {
  type = map(object({
    hostname   = string
    ip         = string
    vcpu       = optional(number, 2)
    memory_mb  = optional(number, 4096)
    disk_gb    = optional(number, 60)
  }))
  default = {}
}