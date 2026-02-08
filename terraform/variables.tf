variable "vpn_chain" {
  description = "Ordered list of VPN nodes. First is entry, last is exit, middle are relays."
  type = list(object({
    name     = string
    provider = string # "digitalocean" or "aws"
    region   = string
    size     = optional(string)
  }))

  validation {
    condition     = length(var.vpn_chain) >= 2
    error_message = "VPN chain must have at least 2 nodes (entry + exit)."
  }

  validation {
    condition     = alltrue([for node in var.vpn_chain : contains(["digitalocean", "aws"], node.provider)])
    error_message = "Each node provider must be 'digitalocean' or 'aws'."
  }

  validation {
    condition     = length(distinct([for node in var.vpn_chain : node.name])) == length(var.vpn_chain)
    error_message = "Node names must be unique."
  }
}

variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
  default     = ""
}

variable "aws_region" {
  description = "Default AWS region for the provider"
  type        = string
  default     = "eu-central-1"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key to install on nodes"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "openvpn_port" {
  description = "OpenVPN listening port"
  type        = number
  default     = 1194
}

variable "wireguard_port" {
  description = "WireGuard listening port"
  type        = number
  default     = 51820
}
