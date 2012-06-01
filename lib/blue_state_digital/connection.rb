require 'rubygems'
require 'openssl'
require 'rest_client'

module BlueStateDigital
  class Connection
    API_VERSION = 1
    API_BASE = '/page/api'
    
    def self.establish(host, api_id, api_secret)
      @@api_id = api_id
      @@api_secret = api_secret
      @@client = RestClient::Resource.new(host)
    end
    
    def self.perform_request(call, params = {}, method = "GET", body = nil)
      path = API_BASE + call
      if method == "POST"
        @@client[path].post body, content_type: 'application/x-www-form-urlencoded', accept: 'text/xml', params: extended_params(path, params)
      else
        @@client[path].get params: extended_params(path, params)
      end
    end
    
    def self.compute_hmac(path, api_ts, params)
      signing_string = [@@api_id, api_ts, path, params.map { |k,v| "#{k.to_s}=#{v.to_s}" }.join('&')].join("\n")                       
      OpenSSL::HMAC.hexdigest('sha1', @@api_secret, signing_string)
    end
    
    def self.extended_params(path, params)
      api_ts = Time.now.utc.to_i.to_s
      extended_params = { api_ver: API_VERSION, api_id: @@api_id, api_ts: api_ts }.merge(params)
      extended_params[:api_mac] = compute_hmac(path, api_ts, extended_params)
      extended_params
    end
  end
end