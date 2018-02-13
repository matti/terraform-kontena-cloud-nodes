output "id" {
  value = "${null_resource.cloud_nodes.id}-${module.until_not_created.id}"
}
