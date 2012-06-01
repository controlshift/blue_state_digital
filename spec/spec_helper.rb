require 'rspec'
require 'webmock/rspec'
Dir[File.join(File.dirname(__FILE__), '../lib/blue_state_digital/*.rb')].each {|file| require file }

RSpec.configure do |config|
  
end