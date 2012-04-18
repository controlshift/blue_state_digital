require 'rubygems'
require 'openssl'
require 'rest_client'
require_relative 'constituent_data_builder'

module BlueStateDigital
  class API
    VERSION = 1
    API_BASE = '/page/api'
    
    def initialize(api_host, api_id, api_secret)
      @api_id = api_id
      @api_secret = api_secret
      @client = RestClient::Resource.new(api_host)
    end
    
    def set_constituent_data(data)
      xml_data = data.is_a?(Hash) ? ConstituentDataBuilder.from_hash(data) : data
      perform_request '/cons/set_constituent_data', {}, "POST", xml_data
    end
    
    def perform_request(call, params = {}, method = "GET", body = nil)
      path = API_BASE + call
      if method == "POST"
        @client[path].post body, content_type: 'application/x-www-form-urlencoded', accept: 'text/xml', params: extended_params(path, params)
      else
        @client[path].get params: extended_params(path, params)
      end
    end
    
    def compute_hmac(path, api_ts, params)
      signing_string = [@api_id, api_ts, path, params.map { |k,v| "#{k.to_s}=#{v.to_s}" }.join('&')].join("\n")                       
      OpenSSL::HMAC.hexdigest('sha1', @api_secret, signing_string)
    end
    
    def extended_params(path, params)
      api_ts = Time.now.utc.to_i.to_s
      extended_params = { api_ver: VERSION, api_id: @api_id, api_ts: api_ts }.merge(params)
      extended_params[:api_mac] = compute_hmac(path, api_ts, extended_params)
      extended_params
    end
  end
end