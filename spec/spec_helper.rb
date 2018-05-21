require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'

  config.before(:each) do
    ::File.stub(:exists?).and_call_original()
    stub_const('File::ALT_SEPARATOR', '\\')
  end
end
