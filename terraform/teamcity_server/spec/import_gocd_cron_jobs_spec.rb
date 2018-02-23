control "import_gocd_cron_jobs" do
  impact 1.0
  title "import_gocd_cron_jobs"
  desc "import_gocd_cron_jobs spec"

  cron_job_dir_daily = '/etc/cron.daily/'
  cron_job_dir_hourly = '/etc/cron.hourly/'

  describe file(File.join(cron_job_dir_daily, 'gocd_agent_pruning')) do
    it { should exist }
    its('owner') { should eq 'root' }
    its('mode') { should cmp '00755' }
  end

  describe file(File.join(cron_job_dir_hourly, 'gocd_ldap_synch')) do
    it { should exist }
    its('owner') { should eq 'root' }
    its('mode') { should cmp '00755' }
  end
end
