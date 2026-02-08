variable "name" {
  description = "Node name"
  type        = string
}

variable "region" {
  description = "DigitalOcean region slug"
  type        = string
}

variable "size" {
  description = "Droplet size slug"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "ssh_key_id" {
  description = "DigitalOcean SSH key resource ID"
  type        = string
}
