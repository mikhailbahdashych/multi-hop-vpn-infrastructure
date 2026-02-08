# --- DigitalOcean Firewalls ---

resource "digitalocean_firewall" "vpn_node" {
  for_each = local.do_nodes

  name       = "${each.value.name}-fw"
  droplet_ids = [module.do_node[each.key].id]

  # SSH access
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # WireGuard from chain peers only
  dynamic "inbound_rule" {
    for_each = each.value.role != "entry" || length(var.vpn_chain) > 1 ? [1] : []
    content {
      protocol         = "udp"
      port_range       = tostring(var.wireguard_port)
      source_addresses = [
        for name, ip in local.node_ips : ip
        if name != each.key
      ]
    }
  }

  # OpenVPN (entry node only)
  dynamic "inbound_rule" {
    for_each = each.value.role == "entry" ? [1] : []
    content {
      protocol         = "udp"
      port_range       = tostring(var.openvpn_port)
      source_addresses = ["0.0.0.0/0", "::/0"]
    }
  }

  # All outbound
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# --- AWS Security Groups ---

resource "aws_security_group" "vpn_node" {
  for_each = local.aws_nodes

  name        = "${each.value.name}-sg"
  description = "Security group for VPN node ${each.value.name}"

  # SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # WireGuard from chain peers
  ingress {
    description = "WireGuard"
    from_port   = var.wireguard_port
    to_port     = var.wireguard_port
    protocol    = "udp"
    cidr_blocks = [for name, ip in local.node_ips : "${ip}/32" if name != each.key]
  }

  # OpenVPN (entry node only)
  dynamic "ingress" {
    for_each = each.value.role == "entry" ? [1] : []
    content {
      description = "OpenVPN"
      from_port   = var.openvpn_port
      to_port     = var.openvpn_port
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # All outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${each.value.name}-sg"
  }
}
