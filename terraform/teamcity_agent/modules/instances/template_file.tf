data "template_file" "user_data" {
  count = "${var.instance_count}"
  template = "${file("${path.module}/user_data.tpl")}"
  vars {                 
    hostname = "${upper(var.env_hostname_prefix)}-${upper(var.service_name)}-${count.index + 1}",
    domain_name = "${var.domain_name}"
    service_name = "${var.service_name}"
  }
} 