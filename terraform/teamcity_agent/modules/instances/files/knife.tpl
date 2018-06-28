log_location STDOUT
node_name "${chef_user_name}"
chef_server_url "${chef_server_url}"
client_key "#{File.dirname(__FILE__)}/${chef_user_name}.pem"
