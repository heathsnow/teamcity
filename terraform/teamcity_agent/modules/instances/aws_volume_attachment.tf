resource "aws_volume_attachment" "log_volume" {
  count = "${var.instance_count}"
  device_name = "/dev/sdi"
  instance_id = "${element(aws_instance.my_instance.*.id, count.index)}"
  volume_id = "${element(split(",", var.log_volume_ids), count.index)}"

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
    inline = [
      "sudo umount -d /dev/xvdi1"
    ]
    when                  = "destroy"
  }
}

resource "aws_volume_attachment" "data_volume" {
  count = "${var.instance_count}"
  device_name = "/dev/sdj"
  instance_id = "${element(aws_instance.my_instance.*.id, count.index)}"
  volume_id = "${element(split(",", var.data_volume_ids), count.index)}"

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
    inline = [
      "sudo umount -d /dev/xvdj1"
    ]
    when                  = "destroy"
  }
}
