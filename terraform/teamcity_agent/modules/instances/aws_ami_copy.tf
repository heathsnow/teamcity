resource "aws_ami_copy" "my_ami_copy" {
  encrypted = true
  name = "${var.ami_name}_terraform_managed_copy"
  source_ami_id = "${data.aws_ami.my_ami.id}"
  source_ami_region = "${var.remote_state_region}"
  lifecycle {
    create_before_destroy = true
  }
}
