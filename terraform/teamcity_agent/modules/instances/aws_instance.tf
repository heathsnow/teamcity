resource "aws_instance" "my_instance" {
  count                  = "${var.instance_count}"
  ami                    = "${aws_ami_copy.my_ami_copy.id}"
  key_name               = "${var.instance_key_name}"
  iam_instance_profile   = "${var.instance_iam_instance_profile}"
  vpc_security_group_ids = ["${split(",", var.instance_security_group_ids)}"]
  instance_type          = "${var.instance_type}"
  subnet_id              = "${element(split(",", var.instance_subnet_ids), count.index)}"
  user_data              = "${element(data.template_file.user_data.*.rendered, count.index)}"

  tags = {
    Name = "${upper(var.env_hostname_prefix)}-${replace(upper(var.hostname_identifier), "_", "-")}-${count.index + 1}"
  }

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      host                = "${self.private_ip}"
      user                = "${var.instance_user}"
      private_key         = "${file("${var.instance_private_key}")}"
      bastion_user        = "${var.bastion_user}"
      bastion_host        = "${var.bastion_host}"
      bastion_port        = "22"
      bastion_private_key = "${file("${var.instance_private_key}")}"
    }
    inline = [
      "sudo systemctl stop teamcity-agent",
      "sudo systemctl stop docker",
      "sudo chef-client -o recipe['daptiv_chef_cleanup']; exit 0"
    ]
    when                  = "destroy"
  }
}
