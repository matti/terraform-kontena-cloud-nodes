output "id" {
  value = "${module.cloud_nodes.id}-${module.until_not_created.id}"
}

output "names" {
  value = "${local.node_names}"
}
