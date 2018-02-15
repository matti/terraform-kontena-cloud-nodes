resource "null_resource" "start" {
  provisioner "local-exec" {
    command = "echo depends_id=${var.depends_id}"
  }
}

module "cloud_nodes" {
  source  = "matti/resource/shell"
  version = "0.2.5"

  depends_id = "${null_resource.start.id}"

  command = <<EOCMD
kontena cloud node create --count ${var.count} --type ${var.type}
EOCMD
}

module "cloud_node_names" {
  source  = "matti/resource/shell"
  version = "0.2.5"

  depends_id = "${module.cloud_nodes.id}"

  # Can not be <<EOCMD, needs shell wrapping not not expand * in "* Provisio..."
  command = "echo \"${module.cloud_nodes.stdout}\" | grep done | cut -d' ' -f5"
}

locals {
  node_names                       = "${split("\n", module.cloud_node_names.stdout)}"
  node_names_separated_with_spaces = "${join(" ", local.node_names)}"
}

# having destroy in cloud_node_names would cause a cycle
module "cloud_nodes_remover" {
  source  = "matti/resource/shell"
  version = "0.2.5"

  command_when_destroy = <<EOCMD
for node in ${local.node_names_separated_with_spaces}; do
  kontena cloud node rm --force $node
done
EOCMD
}

module "until_not_created" {
  source  = "matti/until/shell"
  version = "0.0.2"

  depends_id = "${module.cloud_nodes.id}"
  interval   = 1
  max_tries  = 120

  command = <<EOCMD
nodes_output=$(kontena node ls)
for node in ${local.node_names_separated_with_spaces}; do
  echo $nodes_output | grep $node
done
EOCMD

  stdout_must_not_include = "created"
}
