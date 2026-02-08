locals {
  # Assign roles based on position in chain
  node_roles = {
    for idx, node in var.vpn_chain : node.name => (
      idx == 0 ? "entry" :
      idx == length(var.vpn_chain) - 1 ? "exit" :
      "relay"
    )
  }

  # Filter nodes by provider
  do_nodes = {
    for idx, node in var.vpn_chain : node.name => {
      index    = idx
      name     = node.name
      region   = node.region
      size     = coalesce(node.size, "s-1vcpu-1gb")
      role     = local.node_roles[node.name]
    } if node.provider == "digitalocean"
  }

  aws_nodes = {
    for idx, node in var.vpn_chain : node.name => {
      index    = idx
      name     = node.name
      region   = node.region
      size     = coalesce(node.size, "t3.micro")
      role     = local.node_roles[node.name]
    } if node.provider == "aws"
  }

  # Generate tunnel pairs between adjacent nodes with /30 subnets from 10.0.0.0/16
  # Each pair gets 4 IPs: network, left node, right node, broadcast
  tunnel_pairs = [
    for idx in range(length(var.vpn_chain) - 1) : {
      index     = idx
      left_name = var.vpn_chain[idx].name
      right_name = var.vpn_chain[idx + 1].name
      subnet    = cidrsubnet("10.0.0.0/16", 14, idx) # /30 subnets
      left_ip   = cidrhost(cidrsubnet("10.0.0.0/16", 14, idx), 1)
      right_ip  = cidrhost(cidrsubnet("10.0.0.0/16", 14, idx), 2)
    }
  ]

  # Unified map of all node public IPs (populated from module outputs)
  node_ips = merge(
    { for name, _ in local.do_nodes : name => module.do_node[name].public_ip },
    { for name, _ in local.aws_nodes : name => module.aws_node[name].public_ip }
  )

  # Per-node WireGuard tunnel info for Ansible inventory
  node_wg_tunnels = {
    for node in var.vpn_chain : node.name => {
      tunnels = concat(
        # Tunnel where this node is on the LEFT (outbound to next hop)
        [for pair in local.tunnel_pairs : {
          interface  = local.node_roles[node.name] == "relay" ? "wg_out" : "wg0"
          local_ip   = pair.left_ip
          peer_ip    = pair.right_ip
          peer_public_ip = local.node_ips[pair.right_name]
          direction  = "outbound"
          subnet     = pair.subnet
        } if pair.left_name == node.name],
        # Tunnel where this node is on the RIGHT (inbound from previous hop)
        [for pair in local.tunnel_pairs : {
          interface  = local.node_roles[node.name] == "relay" ? "wg_in" : "wg0"
          local_ip   = pair.right_ip
          peer_ip    = pair.left_ip
          peer_public_ip = local.node_ips[pair.left_name]
          direction  = "inbound"
          subnet     = pair.subnet
        } if pair.right_name == node.name]
      )
    }
  }
}
