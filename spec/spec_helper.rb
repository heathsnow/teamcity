require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'

  config.before(:each) do
    allow(File).to receive(:exists?).and_call_original
    stub_const('File::ALT_SEPARATOR', '\\')
  end
end
