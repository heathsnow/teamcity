variable "bastion_host" {}
variable "bastion_user" {}
variable "config_volume_size" { default = "1" }
variable "data_volume_size" { default = "60" }
variable "env_hostname_prefix" {}
variable "instance_count" {}
variable "instance_private_key" {}
variable "log_volume_size" { default = "10" }
variable "service_name" {}
variable "volume_availability_zones" {}
