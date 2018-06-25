variable "bastion_host" {}
variable "bastion_user" {}
variable "docker_volume_size" { default = "20" }
variable "env_hostname_prefix" {}
variable "hostname_identifier" {}
variable "instance_count" {}
variable "instance_private_key" {}
variable "logs_volume_size" { default = "10" }
variable "volume_availability_zones" {}
variable "work_volume_size" { default = "60" }
