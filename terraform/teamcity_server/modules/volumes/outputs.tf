output "teamcity_server_config_volume_ids" {
  value = "${join(",", aws_ebs_volume.config_volume.*.id)}"
}

output "teamcity_server_data_volume_ids" {
  value = "${join(",", aws_ebs_volume.data_volume.*.id)}"
}

output "teamcity_server_log_volume_ids" {
  value = "${join(",", aws_ebs_volume.log_volume.*.id)}"
}
