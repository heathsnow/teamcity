resource "aws_ebs_volume" "docker_volume" {
  count = "${var.instance_count}"
  availability_zone = "${element(split(",", var.volume_availability_zones), count.index)}"
  size = "${var.docker_volume_size}"
  encrypted = true
  type = "gp2"
  tags {
    Name = "${upper(var.env_hostname_prefix)}-${replace(upper(var.hostname_identifier), "_", "-")}-${count.index + 1}-DOCKER"
  }
}

resource "aws_ebs_volume" "logs_volume" {
  count = "${var.instance_count}"
  availability_zone = "${element(split(",", var.volume_availability_zones), count.index)}"
  size = "${var.logs_volume_size}"
  encrypted = true
  type = "gp2"
  tags {
    Name = "${upper(var.env_hostname_prefix)}-${replace(upper(var.hostname_identifier), "_", "-")}-${count.index + 1}-LOGS"
  }
}

resource "aws_ebs_volume" "work_volume" {
  count = "${var.instance_count}"
  availability_zone = "${element(split(",", var.volume_availability_zones), count.index)}"
  size = "${var.work_volume_size}"
  encrypted = true
  type = "gp2"
  tags {
    Name = "${upper(var.env_hostname_prefix)}-${replace(upper(var.hostname_identifier), "_", "-")}-${count.index + 1}-WORK"
  }
}
