data "terraform_remote_state" "iam" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket}"
    key = "${var.iam_state_file}"
    region = "${var.remote_state_region}"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket}"
    key = "${var.vpc_state_file}"
    region = "${var.remote_state_region}"
  }
}
