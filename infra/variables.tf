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