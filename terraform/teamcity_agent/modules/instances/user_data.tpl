#cloud-config
hostname: ${hostname}
fqdn: ${hostname}.${domain_name}
manage_etc_hosts: true
bootcmd:
  - 'while [ `lsblk -d -n | wc -l` -lt 6 ]; do echo Waiting on EBS volumes...; sleep 5; done'
runcmd:
  - [ mkdir, -p, /opt/${service_name}/log ]
  - [ mkdir, -p, /opt/${service_name}/work ]
disk_setup:
  /dev/xvdi:
    table_type: 'gpt'
    layout: True
    overwrite: False
  /dev/xvdj:
    table_type: 'gpt'
    layout: True
    overwrite: False
fs_setup:
  - label: ${service_name}_log
    filesystem: 'ext4'
    device: '/dev/xvdi1'
  - label: ${service_name}_data
    filesystem: 'ext4'
    device: '/dev/xvdj1'
mounts:
  - [ /dev/xvdi1, /opt/${service_name}/log, "auto", "defaults,nofail", "0", "3" ]
  - [ /dev/xvdj1, /opt/${service_name}/work, "auto", "defaults,nofail", "0", "4" ]
