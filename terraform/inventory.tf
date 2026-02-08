resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/../ansible/inventory/hosts.yml"
  file_permission = "0644"

  content = yamlencode({
    all = {
      children = {
        entry_nodes = {
          hosts = {
            for node in var.vpn_chain : node.name => {
              ansible_host   = local.node_ips[node.name]
              ansible_user   = node.provider == "aws" ? "ubuntu" : "root"
              node_role      = local.node_roles[node.name]
              chain_index    = index(var.vpn_chain[*].name, node.name)
              cloud_provider = node.provider
              wg_tunnels     = local.node_wg_tunnels[node.name].tunnels
              wireguard_port = var.wireguard_port
              openvpn_port   = var.openvpn_port
            } if local.node_roles[node.name] == "entry"
          }
        }
        relay_nodes = {
          hosts = {
            for node in var.vpn_chain : node.name => {
              ansible_host   = local.node_ips[node.name]
              ansible_user   = node.provider == "aws" ? "ubuntu" : "root"
              node_role      = local.node_roles[node.name]
              chain_index    = index(var.vpn_chain[*].name, node.name)
              cloud_provider = node.provider
              wg_tunnels     = local.node_wg_tunnels[node.name].tunnels
              wireguard_port = var.wireguard_port
              openvpn_port   = var.openvpn_port
            } if local.node_roles[node.name] == "relay"
          }
        }
        exit_nodes = {
          hosts = {
            for node in var.vpn_chain : node.name => {
              ansible_host   = local.node_ips[node.name]
              ansible_user   = node.provider == "aws" ? "ubuntu" : "root"
              node_role      = local.node_roles[node.name]
              chain_index    = index(var.vpn_chain[*].name, node.name)
              cloud_provider = node.provider
              wg_tunnels     = local.node_wg_tunnels[node.name].tunnels
              wireguard_port = var.wireguard_port
              openvpn_port   = var.openvpn_port
            } if local.node_roles[node.name] == "exit"
          }
        }
      }
    }
  })
}
