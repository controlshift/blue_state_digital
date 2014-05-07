require 'openssl'
require 'builder'
require 'nokogiri'
require 'crack/xml'
require 'faraday'

# include only required active support dependencies
require 'active_support'
require 'active_support/core_ext/array/grouping.rb'
require 'active_support/core_ext/object/blank.rb'
require 'active_support/core_ext/numeric/time.rb'
require 'active_support/core_ext/object/json.rb'
require 'active_support/core_ext/string/conversions.rb'

require "blue_state_digital/version" unless defined?(BlueStateDigital::VERSION)
require "blue_state_digital/connection"
require "blue_state_digital/collection_resource"
require "blue_state_digital/api_data_model"
require "blue_state_digital/address"
require "blue_state_digital/email"
require "blue_state_digital/phone"
require "blue_state_digital/constituent"
require "blue_state_digital/constituent_group"
require "blue_state_digital/event_type"
require "blue_state_digital/event"
require "blue_state_digital/event_rsvp"
require "blue_state_digital/contribution"
