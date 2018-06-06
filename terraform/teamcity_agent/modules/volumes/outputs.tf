output "teamcity_agent_data_volume_ids" {
  value = "${join(",", aws_ebs_volume.data_volume.*.id)}"
}

output "teamcity_agent_log_volume_ids" {
  value = "${join(",", aws_ebs_volume.log_volume.*.id)}"
}
