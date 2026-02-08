resource "digitalocean_droplet" "node" {
  image    = "ubuntu-24-04-x64"
  name     = var.name
  size     = var.size
  region   = var.region
  ssh_keys = [var.ssh_key_id]

  lifecycle {
    create_before_destroy = true
  }
}
