control "configure_gocd_cipher_key" do
  impact 1.0
  title "configure_gocd_cipher_key"
  desc "configure_gocd_cipher_key spec"

  gocd_cipher_file='/etc/go/cipher'

  describe file(gocd_cipher_file) do
    it { should be_file }
    its('owner') { should eq 'go' }
    its('mode') { should cmp '00664' }
  end
end
