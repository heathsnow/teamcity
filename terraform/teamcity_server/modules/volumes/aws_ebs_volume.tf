resource "aws_ebs_volume" "config_volume" {
  count = "${var.instance_count}"
  availability_zone = "${element(split(",", var.volume_availability_zones), count.index)}"
  size = "${var.config_volume_size}"
  encrypted = true
  type = "gp2"
  tags {
    Name = "${upper(var.env_hostname_prefix)}-${replace(upper(var.service_name), "_", "-")}-${count.index + 1}-CONFIG"
  }
}

resource "aws_ebs_volume" "data_volume" {
  count = "${var.instance_count}"
  availability_zone = "${element(split(",", var.volume_availability_zones), count.index)}"
  size = "${var.data_volume_size}"
  encrypted = true
  type = "gp2"
  tags {
    Name = "${upper(var.env_hostname_prefix)}-${replace(upper(var.service_name), "_", "-")}-${count.index + 1}-DATA"
  }
}

resource "aws_ebs_volume" "log_volume" {
  count = "${var.instance_count}"
  availability_zone = "${element(split(",", var.volume_availability_zones), count.index)}"
  size = "${var.log_volume_size}"
  encrypted = true
  type = "gp2"
  tags {
    Name = "${upper(var.env_hostname_prefix)}-${replace(upper(var.service_name), "_", "-")}-${count.index + 1}-LOG"
  }
}
