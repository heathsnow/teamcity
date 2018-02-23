resource "null_resource" "execute_teamcity_server_configuration" {
  count = "${var.instance_count}"
  depends_on = [
    "aws_volume_attachment.log_volume",
    "aws_volume_attachment.data_volume",
    "aws_volume_attachment.config_volume"
  ]

  triggers {
    instance_ids = "${join(",", aws_instance.my_instance.*.id)}"
  }

  provisioner "file" {
    connection {
      type                = "ssh"
      host                = "${element(aws_instance.my_instance.*.private_ip, count.index)}"
      user                = "${var.instance_user}"
      private_key         = "${file("${var.instance_private_key}")}"
      bastion_user        = "${var.bastion_user}"
      bastion_host        = "${var.bastion_host}"
      bastion_port        = "22"
      bastion_private_key = "${file("${var.instance_private_key}")}"
    }

    source = "${path.module}/files/"
    destination = "/tmp"
    when = "create"
  }

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      host                = "${element(aws_instance.my_instance.*.private_ip, count.index)}"
      user                = "${var.instance_user}"
      private_key         = "${file("${var.instance_private_key}")}"
      bastion_user        = "${var.bastion_user}"
      bastion_host        = "${var.bastion_host}"
      bastion_port        = "22"
      bastion_private_key = "${file("${var.instance_private_key}")}"
    }

    scripts = [
      "${path.module}/scripts/stop_gocd.sh",
      "${path.module}/scripts/create_gocd_ssh_keys.sh",
      "${path.module}/scripts/create_gocd_local_accounts.sh",
      "${path.module}/scripts/configure_gocd_cipher_key.sh",
      "${path.module}/scripts/configure_gocd_plugins.sh",
      "${path.module}/scripts/import_gocd_config.sh",
      "${path.module}/scripts/import_gocd_cron_jobs.sh",
      "${path.module}/scripts/import_trusted_ca_certs.sh",
      "${path.module}/scripts/enable_gocd_automatic_startup.sh",
      "${path.module}/scripts/start_gocd.sh"
    ]

    when = "create"
  }
}
