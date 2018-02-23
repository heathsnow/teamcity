#cloud-config
hostname: ${hostname}
fqdn: ${hostname}.${domain_name}
manage_etc_hosts: true
bootcmd:
  - 'while [ $(lsblk -d -n | wc -l) -lt 7 ]; do echo Waiting on EBS volumes...; sleep 5; done'
disk_setup:
  /dev/xvdi:
    table_type: gpt
    layout: true
    overwrite: false
  /dev/xvdj:
    table_type: gpt
    layout: true
    overwrite: false
  /dev/xvdk:
    table_type: gpt
    layout: true
    overwrite: false
fs_setup:
  - label: go_server_log
    filesystem: ext4
    device: /dev/xvdi1
  - label: go_server_data
    filesystem: ext4
    device: /dev/xvdj1
  - label: go_server_config
    filesystem: ext4
    device: /dev/xvdk1
mounts:
  - [ /dev/xvdi1, /var/log/go-server, auto, 'defaults,nofail', '0', '3' ]
  - [ /dev/xvdj1, /var/lib/go-server, auto, 'defaults,nofail', '0', '4' ]
  - [ /dev/xvdk1, /etc/go, auto, 'defaults,nofail', '0', '5' ]
runcmd:
  - [ chown, go, /var/lib/go-server/ ]
  - [ chown, go, /var/log/go-server/ ]
  - [ chown, go, /etc/go/ ]
  - [ chgrp, go, /var/lib/go-server/ ]
  - [ chgrp, go, /var/log/go-server/ ]
  - [ chgrp, go, /etc/go/ ]
  - [ chmod, 750, /var/lib/go-server/ ]
  - [ chmod, 770, /var/log/go-server/ ]
  - [ chmod, 770, /etc/go/ ]
