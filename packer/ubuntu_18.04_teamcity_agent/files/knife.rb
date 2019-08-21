log_location STDOUT
node_name "deploysvc"
chef_server_url "https://api.opscode.com/organizations/daptiv"
client_key "#{File.dirname(__FILE__)}/deploysvc.pem"
