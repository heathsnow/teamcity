resource "aws_volume_attachment" "docker_volume" {
  count = "${var.instance_count}"
  device_name = "/dev/sdi"
  instance_id = "${element(aws_instance.my_instance.*.id, count.index)}"
  volume_id = "${element(split(",", var.docker_volume_ids), count.index)}"

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
      "sudo systemctl stop teamcity-agent",
      "VOLUME='/dev/xvdi1'; if mount | grep -cqw $VOLUME; then sudo umount -d $VOLUME; fi"
    ]
    when                  = "destroy"
  }
}

resource "aws_volume_attachment" "logs_volume" {
  count = "${var.instance_count}"
  device_name = "/dev/sdj"
  instance_id = "${element(aws_instance.my_instance.*.id, count.index)}"
  volume_id = "${element(split(",", var.logs_volume_ids), count.index)}"

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
      "sudo systemctl stop teamcity-agent",
      "VOLUME='/dev/xvdj1'; if mount | grep -cqw $VOLUME; then sudo umount -d $VOLUME; fi"
    ]
    when                  = "destroy"
  }
}

resource "aws_volume_attachment" "work_volume" {
  count = "${var.instance_count}"
  device_name = "/dev/sdk"
  instance_id = "${element(aws_instance.my_instance.*.id, count.index)}"
  volume_id = "${element(split(",", var.work_volume_ids), count.index)}"

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
      "sudo systemctl stop teamcity-agent",
      "VOLUME='/dev/xvdk1'; if mount | grep -cqw $VOLUME; then sudo umount -d $VOLUME; fi"
    ]
    when                  = "destroy"
  }
}
