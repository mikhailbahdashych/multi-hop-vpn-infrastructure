data "local_file" "ssh_public_key" {
  filename = pathexpand(var.ssh_public_key_path)
}

resource "digitalocean_ssh_key" "vpn" {
  count      = length(local.do_nodes) > 0 ? 1 : 0
  name       = "multi-hop-vpn"
  public_key = trimspace(data.local_file.ssh_public_key.content)
}

resource "aws_key_pair" "vpn" {
  count      = length(local.aws_nodes) > 0 ? 1 : 0
  key_name   = "multi-hop-vpn"
  public_key = trimspace(data.local_file.ssh_public_key.content)
}
