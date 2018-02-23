variable "bastion_host" {}
variable "bastion_user" { default = "ubuntu" }
variable "domain_name" {}
variable "env_hostname_prefix" {}
variable "iam_state_file" {}
variable "instance_key_name" {}
variable "instance_private_key" {}
variable "teamcity_server_ami_name" { default = "CoreOS-stable-1235.9.0-hvm" }
variable "teamcity_server_ami_owners" { default = "595879546273" }
variable "teamcity_server_config_volume_size" { default = "1" }
variable "teamcity_server_data_volume_size" { default = "60" }
variable "teamcity_server_instance_count" { default = "1" }
variable "teamcity_server_instance_type" { default = "t2.medium" }
variable "teamcity_server_instance_user" { default = "core" }
variable "teamcity_server_log_volume_size" { default = "10" }
variable "teamcity_server_service_name" { default = "teamcity-server" }
variable "remote_state_bucket" {}
variable "remote_state_region" {}
variable "vpc_state_file" {}
variable "wildcard_ssl_cert_arn" {}
