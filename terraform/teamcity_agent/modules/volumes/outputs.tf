output "teamcity_agent_docker_volume_ids" {
  value = "${join(",", aws_ebs_volume.docker_volume.*.id)}"
}

output "teamcity_agent_logs_volume_ids" {
  value = "${join(",", aws_ebs_volume.logs_volume.*.id)}"
}

output "teamcity_agent_work_volume_ids" {
  value = "${join(",", aws_ebs_volume.work_volume.*.id)}"
}
