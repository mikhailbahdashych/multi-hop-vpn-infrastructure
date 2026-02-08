module "do_node" {
  source   = "./modules/digitalocean-node"
  for_each = local.do_nodes

  name       = each.value.name
  region     = each.value.region
  size       = each.value.size
  ssh_key_id = digitalocean_ssh_key.vpn[0].id
}

module "aws_node" {
  source   = "./modules/aws-node"
  for_each = local.aws_nodes

  name         = each.value.name
  region       = each.value.region
  instance_type = each.value.size
  key_name     = aws_key_pair.vpn[0].key_name
}
