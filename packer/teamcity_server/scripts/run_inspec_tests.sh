echo "Running inspec tests..."
inspec exec /src/spec/*_spec.rb \
  --target=ssh://ubuntu@$1:22 -i "/root/.ssh/${EC2_KEYPAIR_NAME}.pem"
