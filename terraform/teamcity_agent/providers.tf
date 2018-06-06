provider "aws" {
  region = "${var.remote_state_region}"
  version = "~> 1.1.0"
}

provider "null" {
  version = "~> 1.0.0"
}

provider "template" {
  version = "~> 1.0.0"
}

provider "terraform" {
  version = "~> 1.0.0"
}
