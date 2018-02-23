resource "aws_elb" "my_elb" {
  name = "${replace(lower(var.service_name), "_", "-")}"
  subnets = ["${split(",", var.elb_subnet_ids)}"]
  security_groups = ["${split(",", var.elb_security_groups_ids)}"]
  cross_zone_load_balancing = true
  connection_draining = true
  internal = true

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  listener {
    instance_port = 8153
    instance_protocol = "http"
    lb_port = 8153
    lb_protocol = "http"
  }

  listener {
    instance_port = 8154
    instance_protocol = "tcp"
    lb_port = 8154
    lb_protocol = "tcp"
  }

  listener {
    instance_port = 8153
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${var.elb_ssl_certificate_id}"
  }

  health_check {
    healthy_threshold = 10
    unhealthy_threshold = 5
    timeout = 5
    interval = 30
    target = "HTTP:8153/go/auth/login"
  }
}
