require 'openssl'
require 'rest_client'
require 'builder'
require 'nokogiri'
require 'active_support/core_ext'
require 'crack/xml'
require 'faraday'

require "blue_state_digital/version" unless defined?(BlueStateDigital::VERSION)
require "blue_state_digital/connection"
require "blue_state_digital/collection_resource"
require "blue_state_digital/api_data_model"
require "blue_state_digital/address"
require "blue_state_digital/email"
require "blue_state_digital/phone"
require "blue_state_digital/constituent"
require "blue_state_digital/constituent_group"
