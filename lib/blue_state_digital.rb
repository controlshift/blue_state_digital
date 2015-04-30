require 'openssl'
require 'builder'
require 'nokogiri'
# There's a bug on Active Support that doesn't require the Autoload for core_ext classes
require 'active_support/dependencies/autoload'
require 'active_support/core_ext'
require 'active_model'
require 'csv'
require 'crack/xml'
require 'faraday'
require 'hashie'

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
require "blue_state_digital/dataset"
require "blue_state_digital/dataset_map"
require "blue_state_digital/error_middleware"


I18n.enforce_available_locales = false

Faraday::Response.register_middleware :error_middleware  => lambda { BlueStateDigital::ErrorMiddleware }