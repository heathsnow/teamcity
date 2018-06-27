resource "null_resource" "execute_teamcity_agent_configuration" {
  count = "${var.instance_count}"
  depends_on = [
    "aws_volume_attachment.docker_volume",
    "aws_volume_attachment.logs_volume",
    "aws_volume_attachment.work_volume"
  ]

  triggers {
    timestamp = "${timestamp()}"
  }

  provisioner "chef" {
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

    environment     = "${var.chef_environment}"
    run_list        = ["daptiv_ec2_environment", "daptiv_buildagent_ubuntu_role", "daptiv_teamcity"]
    node_name       = "${upper(var.env_hostname_prefix)}-${upper(var.hostname_identifier)}-${count.index + 1}"
    secret_key      = "${file("${var.secret_key_file}")}"
    server_url      = "${var.chef_server_url}"
    recreate_client = true
    user_name       = "${var.chef_user_name}"
    user_key        = "${file("${var.user_key_file}")}"
    version         = "${var.chef_version}"
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
      "${path.module}/scripts/create_chef_keys.sh",
      "${path.module}/scripts/create_ssh_keys.sh"
    ]

    when = "create"
  }
}
