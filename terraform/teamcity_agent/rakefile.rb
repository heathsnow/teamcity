# ------------------------------
# HOW TO CUSTOMIZE THIS RAKEFILE
# ------------------------------
#
# 1. Modify 'gems' array to include all gems named in 'require' statements.
# 2. Modify @defaults hash to set global default Rakefile behavior.
# 3. Modify 'build_variables' function to assign any conditional/interpolated variables to @vars.
# 4. Modify 'common_flags' function to pass required vars from @vars when calling Terraform.
# 5. Modify 'verify_service' function to perform basic EVTs.
# 6. Update 'help' task.

$stderr.sync = true
$stdout.sync = true

gems = %w(colorize json)
puts 'Installing gems...'
gems.each do |g|
  begin
    gem g
  rescue Gem::LoadError
    system "gem install #{g} --no-document"
    Gem.clear_paths
  end
  require g
end

@vars = {}
@defaults = {
  bastion_required: true,
  private_key_dir: '~/.ssh/',
  service_name: 'teamcity_agent',
  slack_technology_emojis: ':terraform: :chef: :teamcity:',
  tf_action: '',
  tf_destroy_targets: '',
  user_key_dir: '~/.chef/'
}

task default: [:help]

desc 'Display Rakefile help.'
task :help do
  system 'rake -sT'
  puts ''
  puts 'Required environment variables:'.red
  puts "  AWS_ACCESS_KEY_ID (current: '#{ENV['AWS_ACCESS_KEY_ID']}')".red
  puts "  AWS_SECRET_ACCESS_KEY (current: '#{ENV['AWS_SECRET_ACCESS_KEY']}')".red
  puts "  TF_VARIABLE_FILE (current: '#{ENV['TF_VARIABLE_FILE']}')".red
  puts "  TF_VARIABLE_PATH (current: '#{ENV['TF_VARIABLE_PATH']}')".red
  puts ''
  puts 'Optional environment variables:'.yellow
  puts "  SERVICE_NAME (default: '#{@defaults[:service_name]}')".yellow
  puts "  TF_DESTROY_TARGETS (default: '#{@defaults[:tf_destroy_targets]}')".yellow
  puts ''
  puts 'Example of deploying a configuration:'.green
  puts '  export AWS_ACCESS_KEY_ID=MyAccessKey'.green
  puts '  export AWS_SECRET_ACCESS_KEY=MySecretKey'.green
  puts '  export TF_VARIABLE_FILE=us_blu.tfvars'.green
  puts '  export TF_VARIABLE_PATH=../../terraform_environment/variables/'.green
  puts '  rake deploy'.green
  puts ''
  puts 'Example of destroying a configuration:'.green
  puts '  export AWS_ACCESS_KEY_ID=MyAccessKey'.green
  puts '  export AWS_SECRET_ACCESS_KEY=MySecretKey'.green
  puts '  export TF_DESTROY_TARGETS=all'.green
  puts '  export TF_VARIABLE_FILE=us_blu.tfvars'.green
  puts '  export TF_VARIABLE_PATH=../../terraform_environment/variables/'.green
  puts '  rake destroy'.green
end

desc 'Validate Terraform configuration.'
task :validate do
  puts 'Validating Terraform configuration...'.green
  begin
    Rake::Task[:version_info].invoke
    build_variables
    Rake::Task[:assume_role].invoke
    assign_bastion_host
    terraform_init
    sh "terraform validate #{common_flags}"
  ensure
    cleanup
  end
end

desc 'Deploy Terraform configuration.'
task :deploy do
  Rake::Task[:version_info].invoke
  build_variables
  Rake::Task[:assume_role].invoke
  assign_bastion_host
  terraform_deploy
end

desc 'Plan Terraform configuration.'
task :plan do
  Rake::Task[:version_info].invoke
  build_variables
  Rake::Task[:assume_role].invoke
  assign_bastion_host
  begin
    cleanup
    terraform_init
    sh "terraform plan #{common_flags}"
  ensure
    cleanup
  end
end

desc 'Destroy Terraform configuration.'
task :destroy do
  Rake::Task[:version_info].invoke
  build_variables
  Rake::Task[:assume_role].invoke
  assign_bastion_host
  terraform_destroy
end

desc 'Verify operational status of deployed resources.'
task :verify do
  Rake::Task[:version_info].invoke
  action = ENV['TF_ACTION'].to_s.empty? ? @defaults[:tf_action] : ENV['TF_ACTION']
  case action.downcase
  when 'destroy'
    puts 'Infrastructure destroyed, no verification required'.green
  else
    puts 'Beginning verification...'.green
    Rake::Task[:assume_role].invoke
    assign_bastion_host
    verify_service
  end
end

desc 'List versions of installed utilities.'
task :version_info do
  puts 'Listing utility versions...'.green
  system 'aws --version'
  system 'terraform -v'
end

desc 'List IP addresses of bastion hosts.'
task :bastion_hosts do
  Rake::Task[:version_info].invoke
  build_variables
  Rake::Task[:assume_role].invoke
  puts "Listing IP addresses of bastion hosts in #{@vars[:env_name]}...".green
  bastion_host_ips.each_with_index do |ip, index|
    puts "#{index + 1}: #{ip}"
  end
end

desc 'Assume AWS deployment role specified in environment tfvars.'
task :assume_role do
  build_variables if @vars.empty?

  puts "Assuming role in #{@vars[:env_name]}...".green

  ENV['AWS_DEFAULT_REGION'] = @vars[:default_region]
  ENV['AWS_ACCESS_KEY_ID'] = @vars[:aws_access_key_id]
  ENV['AWS_SECRET_ACCESS_KEY'] = @vars[:aws_secret_access_key]

  assume_role_cmd = 'aws sts assume-role ' \
    "--role-arn=#{@vars[:deployment_role_arn]} " \
    '--role-session-name=temp_session'

  begin
    data = JSON.parse(`#{assume_role_cmd}`)
  rescue JSON::ParserError
    abort 'Command \'aws sts assume-role\' returned invalid JSON.'.red
  end

  aws_access_key_id = data['Credentials']['AccessKeyId']
  aws_secret_access_key = data['Credentials']['SecretAccessKey']
  session_token = data['Credentials']['SessionToken']

  system "aws configure set aws_access_key_id #{aws_access_key_id}"
  system "aws configure set aws_secret_access_key #{aws_secret_access_key}"
  system "aws configure set aws_session_token #{session_token}"
  system "aws configure set region #{@vars[:default_region]}"

  ENV['AWS_ACCESS_KEY_ID'] = nil
  ENV['AWS_SECRET_ACCESS_KEY'] = nil

  puts "Role '#{@vars[:deployment_role_arn][/\w+$/]}' has been assumed.".green
end

desc 'Send started/passed/failed notification.'
task :notify, [:type] do |_t, args|
  notify_prefix = 'curl -X POST --data-urlencode "payload={\"channel\": ' \
    '\"##dp_deploy\", \"username\": \"GoCD\", \"text\": \"' \
    "#{@defaults[:slack_technology_emojis]} " \
    "<#{ENV['GO_SERVER_URL']}/go/pipelines/#{ENV['GO_PIPELINE_NAME']}/" \
    "#{ENV['GO_PIPELINE_COUNTER']}/#{ENV['GO_STAGE_NAME']}/" \
    "#{ENV['GO_STAGE_COUNTER']}|#{ENV['GO_PIPELINE_NAME']}> "

  case args[:type]
  when 'started'
    type_text = 'started.'
  when 'passed'
    type_text = 'deployment complete. :beers:'
  when 'failed'
    type_text = " *FAILED* at the <#{ENV['GO_SERVER_URL']}/go/tab/build/" \
      "detail/#{ENV['GO_PIPELINE_NAME']}/#{ENV['GO_PIPELINE_COUNTER']}/" \
      "#{ENV['GO_STAGE_NAME']}/#{ENV['GO_STAGE_COUNTER']}/" \
      "#{ENV['GO_JOB_NAME']}|#{ENV['GO_STAGE_NAME']}> stage! :poop:"
  end

  notify_suffix = '\", \"icon_emoji\": \":gocd:\"}" ' \
    'https://hooks.slack.com/services/' \
    "#{ENV['SLACK_URL_SUFFIX']}"

  cmd = notify_prefix + type_text + notify_suffix
  system cmd
end

desc 'Clean up terraform directory.'
task :cleanup do
  cleanup
end

private

def load_tfvars
  puts "Loading variables from '#{@vars[:tfvars_file]}'...".green

  begin
    @file = File.new(@vars[:tfvars_file], 'r')
  rescue => e
    abort e.message
  end

  while (line = @file.gets)
    next if line.match(/^[#\s]/)
    line.scan(/(\w+)\s*=\s*"(.*)"/).map{ |k, v| @vars.store(k.to_sym, v) }
  end
  @file.close
end

def build_variables
  @vars[:tfvars_file] = File.join(ENV['TF_VARIABLE_PATH'], ENV['TF_VARIABLE_FILE'])
  load_tfvars

  puts 'Building additional variables...'.green
  @vars[:service_name] = ENV['SERVICE_NAME'].to_s.empty? ? @defaults[:service_name].downcase.tr('_', '-') : ENV['SERVICE_NAME'].downcase.tr('_', '-')
  @vars[:tf_destroy_targets] = (ENV['TF_DESTROY_TARGETS'].to_s.empty? ? @defaults[:tf_destroy_targets] : ENV['TF_DESTROY_TARGETS']).downcase

  @vars[:default_region] = @vars[:remote_state_region]
  @vars[:deployment_role_arn] = @vars[:go_role_arn]
  @vars[:aws_access_key_id] = ENV['AWS_ACCESS_KEY_ID'].to_s.empty? ? ENV['GO_AWS_ACCESS_KEY_ID'] : ENV['AWS_ACCESS_KEY_ID']
  @vars[:aws_secret_access_key] = ENV['AWS_SECRET_ACCESS_KEY'].to_s.empty? ? ENV['GO_AWS_SECRET_ACCESS_KEY'] : ENV['AWS_SECRET_ACCESS_KEY']

  @vars[:remote_state_file] = @vars["#{@vars[:service_name].tr('-', '_')}_state_file".to_sym]
  @vars[:instance_private_key] = "#{@defaults[:private_key_dir]}#{@vars[:instance_key_name]}.pem"
  @vars[:secret_key_file] = ENV['CHEF_SECRET_FILE'].to_s.empty? ? @vars[:secret_key_file] : ENV['CHEF_SECRET_FILE']
  @vars[:user_key_file] = "#{@defaults[:user_key_dir]}deploysvc.pem"
end

def targets
  return if @vars[:tf_destroy_targets] == 'all'
  if !@vars[:tf_destroy_targets].empty?
    targets = ''
    @vars[:tf_destroy_targets].split(',').each do |target|
      targets += "-target=#{target} "
    end
    return targets
  end
  abort 'Must set TF_DESTROY_TARGETS=all or TF_DESTROY_TARGETS=resource.name.'.red
end

def common_flags
  flags =
    "-var \"instance_private_key=#{@vars[:instance_private_key]}\" " \
    "-var \"secret_key_file=#{@vars[:secret_key_file]}\" " \
    "-var \"user_key_file=#{@vars[:user_key_file]}\" " \
    "-var-file=\"#{@vars[:tfvars_file]}\""
  return flags unless @vars[:bastion_host]
  "-var \"bastion_host=#{@vars[:bastion_host]}\" " + flags
end

def terraform_init
  sh 'terraform init ' \
     '-backend=true ' \
     "-backend-config=\"bucket=#{@vars[:remote_state_bucket]}\" " \
     "-backend-config=\"key=#{@vars[:remote_state_file]}\" " \
     "-backend-config=\"region=#{@vars[:remote_state_region]}\" " \
     '-force-copy ' \
     '-get=true ' \
     '-lock=true'
end

def terraform_deploy
  puts 'Deploying Terraform configuration...'.green

  cleanup
  terraform_init
  sh "terraform plan #{common_flags}"
  sh "terraform apply #{common_flags} -auto-approve -backup=\"-\""
ensure
  cleanup
end

def terraform_destroy
  puts 'Destroying Terraform configuration...'.green

  cleanup
  terraform_init
  sh "terraform plan -destroy #{targets} #{common_flags}"
  destroy_countdown
  sh "terraform destroy -force #{targets} #{common_flags}"
ensure
  cleanup
end

def verify_service
  puts "Verifying #{@vars[:service_name]}...".green
  puts 'TODO: IMPLEMENT SERVICE VERIFICATION'.red
end

def assign_bastion_host
  if @defaults[:bastion_required]
    @vars[:bastion_host] = bastion_host_ips.sample
    if @vars[:bastion_host].to_s.empty?
      abort 'A bastion host is required, but none were found.'.red
    end
  end
end

def bastion_host_ips
  cmd = 'aws ec2 describe-instances ' \
    '--query "Reservations[].Instances[].PrivateIpAddress" ' \
    '--filter "Name=instance.group-name,Values=BASTION_LINUX" ' \
    '"Name=instance-state-name,Values=running" --output text'
  IO.popen(cmd).read.split
end

def destroy_countdown
  puts 'About to DESTROY infrastructure.'.yellow
  10.times do |i|
    puts "T-minus #{10 - i}...".yellow
    sleep 2
  end
end

def cleanup
  sh 'rm -rf .terraform'
end
