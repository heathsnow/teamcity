control "import_trusted_ssl_certs" do
  impact 1.0
  title "import_trusted_ssl_certs"
  desc "import_trusted_ssl_certs spec"

  certs = [
    'eu-ca01.eu.daptiv.cloud.pem',
    'eu-dc01.eu.daptiv.cloud.pem',
    'eu-dc02.eu.daptiv.cloud.pem',
    'eu-dc03.eu.daptiv.cloud.pem',
    'us-ca01.us.daptiv.cloud.pem',
    'us-dc01.us.daptiv.cloud.pem',
    'us-dc02.us.daptiv.cloud.pem',
    'us-dc03.us.daptiv.cloud.pem'
  ]

  certs.each do |cert|
    describe file(File.join('/etc/ssl/certs/', cert)) do
      it { should exist }
    end
  end
end
