variable "bastion_host" {}
variable "bastion_user" { default = "ubuntu" }
variable "chef_environment" { default = "cookbook_ci" }
variable "chef_server_url" { default = "https://api.opscode.com/organizations/daptiv" }
variable "chef_user_name" { default = "deploysvc" }
variable "chef_version" { default = "12.16.42" }
variable "domain_name" {}
variable "env_hostname_prefix" {}
variable "instance_key_name" {}
variable "instance_private_key" {}
variable "teamcity_agent_ami_name" { default = "ubuntu_18.04" }
variable "teamcity_agent_ami_owners" { default = "147491244536" }
variable "teamcity_agent_data_volume_size" { default = "60" }
variable "teamcity_agent_instance_count" { default = "1" }
variable "teamcity_agent_instance_type" { default = "t2.medium" }
variable "teamcity_agent_instance_user" { default = "ubuntu" }
variable "teamcity_agent_log_volume_size" { default = "10" }
variable "teamcity_agent_service_name" { default = "teamcity_agent" }
variable "remote_state_bucket" {}
variable "remote_state_region" {}
variable "secret_key_file" { default = "/etc/chef/encrypted_data_bag_secret" }
variable "user_key_file" {}
variable "vpc_state_file" {}
