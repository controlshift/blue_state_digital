require 'rspec'
require 'webmock/rspec'

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'blue_state_digital'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|

end

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.new(File.join(fixture_path, '/', file))
end

