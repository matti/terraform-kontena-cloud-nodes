variable "organization" {}
variable "name" {}

module "platform" {
  source       = "matti/cloud-platform/kontena"
  organization = "${var.organization}"
  name         = "${var.name}"
}

module "nodes" {
  source = ".."

  depends_id = "${module.platform.id}"
  count      = 3
  type       = "k1"
}

output "names" {
  value = "${module.nodes.names}"
}
