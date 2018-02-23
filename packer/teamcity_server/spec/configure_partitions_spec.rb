control "configure_partitions-1.0" do
  impact 1.0
  title "configure_partitions"
  desc "configure_partitions spec"

  describe command('free | grep "Swap:             "') do
    its('exit_status') { should eq 1 }
  end

  describe etc_fstab.where { mount_point == '/var/log' } do
    its('device_name') { should cmp '/dev/xvdg1' }
  end

  describe etc_fstab.where { mount_point == '/home' } do
    its('device_name') { should cmp '/dev/xvdh1' }
  end
end
