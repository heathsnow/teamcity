data "aws_ami" "my_ami" {
  most_recent = true
  owners = ["${split(",", var.ami_owners)}"]
  filter {
    name = "name"
    values = ["${var.ami_name}"]
  }
}
