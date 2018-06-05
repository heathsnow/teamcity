task default: [:help]

desc 'Packer Build.'
# task :build, [:type] => [:assume_role] do |_t, args|
task :build do
  task_thread = []
  packer_complete = false
  start_time = Time.now
  # %w(packer assume_role).each do |task|
  %w(packer).each do |task|
    task_thread << Thread.new do
      case task
      when 'packer'
        load_gems('colorize')
        puts 'Running Packer Build...'.green
        packer_file = ENV['PACKER_FILE'] || 'packer.json'
        begin
          sh "packer build #{packer_file}"
        rescue StandardError => e
          raise e.inspect
        end
        packer_complete = true
      when 'assume_role'
        while packer_complete == false
          current_time = Time.now
          elapsed_time = (current_time.to_f - start_time.to_f).to_i
          if elapsed_time > 3000
            Rake::Task[:assume_role].reenable
            Rake::Task[:assume_role].invoke
            start_time = Time.now
          end
          sleep 10
        end
      end
    end
  end
  task_thread.each(&:join)
end

desc 'AWS Assume Role.'
task :assume_role do
  load_gems('json colorize')
  puts "Assuming role for #{ENV['EC2_ROLE_ARN']}".green

  assume_role_cmd = 'aws sts assume-role ' \
   "--role-arn=#{ENV['EC2_ROLE_ARN']} " \
   '--role-session-name=temp_session'
  data = JSON.parse(`#{assume_role_cmd}`)
  
  access_key = data['Credentials']['AccessKeyId']                                          
  secret_key = data['Credentials']['SecretAccessKey']
  token = data['Credentials']['SessionToken']

  system "aws configure set aws_access_key_id #{access_key}"
  system "aws configure set aws_secret_access_key #{secret_key}"
  system "aws configure set aws_session_token #{token}"

  ENV['AWS_ACCESS_KEY_ID'] = nil
  ENV['AWS_SECRET_ACCESS_KEY'] = nil
  ENV['AWS_SESSION_TOKEN'] = token

  puts "Role '#{ENV['EC2_ROLE_ARN']}' has been assumed.".green
end

desc 'Output help text.'
task :help do
  load_gems('colorize')
  puts 'How to execute this script:'.green
  puts '  $> rake build'.green
  puts 'Required Environment Variables:'.yellow
  puts "  $> export AWS_ACCESS_KEY_ID=your_aws_access_key (current: #{ENV['AWS_ACCESS_KEY_ID']})".yellow
  puts "  $> export AWS_CRED_DIR=your_aws_profile_dir (current: #{ENV['AWS_CRED_DIR']})".yellow
  puts "  $> export AWS_SECRET_ACCESS_KEY=your_aws_secret_access_key (current: #{ENV['AWS_SECRET_ACCESS_KEY']})".yellow
  puts "  $> export EC2_AMI_REGION=list_of_regions (current: #{ENV['EC2_AMI_REGION']})".yellow
  puts "  $> export EC2_AMI_USERS=list_of_account_ids (current: #{ENV['EC2_AMI_USERS']})".yellow
  puts "  $> export EC2_ROLE_ARN=role_arn_for_grn (current: #{ENV['EC2_ROLE_ARN']})".yellow
  puts "  $> export EC2_SUBNET_ID=role_arn_for_grn (current: #{ENV['EC2_SUBNET_ID']})".yellow
  puts "  $> export EC2_VPC_ID=role_arn_for_grn (current: #{ENV['EC2_VPC_ID']})".yellow
  puts "  $> export PACKER_FILE=your_packer_file.json (current: #{ENV['PACKER_FILE']})".yellow
end

private

def load_gems(gems)
  gems.split(' ').each do |g|
    begin
      gem g
    rescue Gem::LoadError
      system "gem install #{g} --no-document"
      Gem.clear_paths
    end
    require g
  end
end
