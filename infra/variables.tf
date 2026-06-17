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
  default = "ups.1c2g"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}

variable "admin_cidr" {
  type = string
}

variable "ssh_authorized_keys" {
  description = "Public SSH keys allowed to log into the VM."
  type        = list(string)
}