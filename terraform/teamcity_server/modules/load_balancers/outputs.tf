output "teamcity_server_elb_dns_name" {
  value = "${aws_elb.my_elb.dns_name}"
}

output "teamcity_server_elb_name" {
  value = "${aws_elb.my_elb.name}"
}
