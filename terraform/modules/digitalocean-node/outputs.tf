output "public_ip" {
  description = "Public IPv4 address of the droplet"
  value       = digitalocean_droplet.node.ipv4_address
}

output "id" {
  description = "Droplet ID"
  value       = digitalocean_droplet.node.id
}
