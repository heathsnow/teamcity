data "template_file" "user_data" {
  count = "${var.instance_count}"
  template = "${file("${path.module}/user_data.tpl")}"
  vars {                 
    hostname = "${upper(var.env_hostname_prefix)}-${replace(upper(var.service_name), "_", "-")}-${count.index + 1}",
    domain_name = "${var.domain_name}"
  }
} 
