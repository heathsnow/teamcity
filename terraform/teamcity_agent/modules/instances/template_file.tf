data "template_file" "user_data" {
  count = "${var.instance_count}"
  template = "${file("${path.module}/files/user_data.tpl")}"
  vars {
    hostname = "${upper(var.env_hostname_prefix)}-${replace(upper(var.hostname_identifier), "_", "-")}-${count.index + 1}",
    domain_name = "${var.domain_name}"
    service_name = "${var.service_name}"
  }
}

data "template_file" "knife" {
  template = "${file("${path.module}/files/knife.tpl")}"
  vars {
    chef_server_url = "${var.chef_server_url}"
    chef_user_name = "${var.chef_user_name}"  
  }
}
