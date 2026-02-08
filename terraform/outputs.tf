output "node_ips" {
  description = "Public IP addresses of all VPN chain nodes"
  value       = local.node_ips
}

output "entry_node_ip" {
  description = "Public IP of the entry node (OpenVPN endpoint)"
  value       = local.node_ips[var.vpn_chain[0].name]
}

output "exit_node_ip" {
  description = "Public IP of the exit node (internet-facing)"
  value       = local.node_ips[var.vpn_chain[length(var.vpn_chain) - 1].name]
}

output "chain_summary" {
  description = "Summary of the VPN chain"
  value = [
    for idx, node in var.vpn_chain : {
      name = node.name
      role = local.node_roles[node.name]
      ip   = local.node_ips[node.name]
      provider = node.provider
      region   = node.region
    }
  ]
}
