resource "null_resource" "start" {
  provisioner "local-exec" {
    command = "echo depends_id=${var.depends_id}"
  }
}

resource "null_resource" "cloud_nodes" {
  provisioner "local-exec" {
    command = "kontena cloud node create --count ${var.count} --type ${var.type}"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "kontena cloud node ls -q | xargs -L1 kontena cloud node rm --force"
  }
}
