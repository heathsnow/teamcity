resource "aws_elb_attachment" "my_elb_attachment" {
  elb = "${var.load_balancer}"
  instance = "${aws_instance.my_instance.id}"
}
