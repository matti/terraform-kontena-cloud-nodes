resource "null_resource" "start" {
  provisioner "local-exec" {
    command = "echo depends_id=${var.depends_id}"
  }
}

resource "null_resource" "cloud_nodes" {
  depends_on = "null_resource.start"

  triggers {
    type  = "${var.type}"
    count = "${var.count}"
  }

  provisioner "local-exec" {
    command = "kontena cloud node create --count ${var.count} --type ${var.type}"
  }
}

module "until_not_created" {
  source  = "matti/until/shell"
  version = "0.0.2"

  depends_id = "${null_resource.cloud_nodes.id}"

  command = "kontena node ls | grep created"

  stdout_must_not_include = "created"
}
