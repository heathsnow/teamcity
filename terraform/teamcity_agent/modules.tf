module "instances_ubuntu" {
  source = "modules/instances"
  ami_name = "${var.teamcity_agent_ami_name}"
  ami_owners = "${var.teamcity_agent_ami_owners}"
  bastion_host = "${var.bastion_host}"
  bastion_user = "${var.bastion_user}"
  chef_environment = "${var.chef_environment}"
  chef_server_url = "${var.chef_server_url}"
  chef_user_name = "${var.chef_user_name}"
  chef_version = "${var.chef_version}"
  data_volume_ids = "${module.volumes.teamcity_agent_data_volume_ids}"
  domain_name = "${var.domain_name}"
  env_hostname_prefix = "${var.env_hostname_prefix}"
  hostname_identifier = "${var.teamcity_agent_hostname_identifier}"
  instance_count = "${var.teamcity_agent_instance_count}"
  instance_key_name = "${var.instance_key_name}"
  instance_private_key = "${var.instance_private_key}"
  instance_security_group_ids = "${data.terraform_remote_state.vpc.linuxcoreservices_sg_id},${data.terraform_remote_state.vpc.teamcity_agent_sg_id}"
  instance_subnet_ids = "${data.terraform_remote_state.vpc.private_subnet_id_list}"
  instance_type = "${var.teamcity_agent_instance_type}"
  instance_user = "${var.teamcity_agent_instance_user}"
  log_volume_ids = "${module.volumes.teamcity_agent_log_volume_ids}"
  remote_state_region = "${var.remote_state_region}"
  secret_key_file = "${var.secret_key_file}"
  service_name = "${var.teamcity_agent_service_name}"
  user_key_file = "${var.user_key_file}"
}

module "volumes_ubuntu" {
  source = "modules/volumes"
  bastion_host = "${var.bastion_host}"
  bastion_user = "${var.bastion_user}"
  data_volume_size = "${var.teamcity_agent_data_volume_size}"
  env_hostname_prefix = "${var.env_hostname_prefix}"
  hostname_identifier = "${var.teamcity_agent_hostname_identifier}"
  instance_count = "${var.teamcity_agent_instance_count}"
  instance_private_key = "${var.instance_private_key}"
  log_volume_size = "${var.teamcity_agent_log_volume_size}"
  service_name = "${var.teamcity_agent_service_name}"
  volume_availability_zones = "${data.terraform_remote_state.vpc.private_subnet_availability_zone_list}"
}
