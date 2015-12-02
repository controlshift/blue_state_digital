module BlueStateDigital
  class DeferredResultTimeout < StandardError ; end

  class Connection
    API_VERSION = 2
    API_BASE = '/page/api'
    GRAPH_API_BASE = '/page/graph'

    attr_reader :constituents, :constituent_groups, :datasets, :dataset_maps

    def initialize(params = {})
      @api_id = params[:api_id]
      @api_secret = params[:api_secret]
      @client = Faraday.new(:url => "https://#{params[:host]}/") do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        if defined?(Rails) && Rails.env.development?
          faraday.response :logger                  # log requests to STDOUT
        end
        faraday.response :error_middleware
        faraday.adapter(params[:adapter] || Faraday.default_adapter)  # make requests with Net::HTTP by default
      end
      set_up_resources
    end

    def perform_request(call, params = {}, method = "GET", body = nil)
      perform_request_raw(call,params,method,body).body
    end

    def perform_request_raw(call, params = {}, method = "GET", body = nil)
      path = API_BASE + call
      if method == "POST" || method == "PUT"
        @client.send(method.downcase.to_sym) do |req|
          content_type = params.delete(:content_type) || 'application/x-www-form-urlencoded'
          accept = params.delete(:accept) || 'text/xml'
          req.url(path, extended_params(path, params))
          req.body = body
          req.options.timeout = 120
          req.headers['Content-Type'] = content_type
          req.headers['Accept'] = accept
        end
      else
        @client.get(path, extended_params(path, params))
      end
    end

    def perform_graph_request(call, params, method = 'POST')
      path = GRAPH_API_BASE + call

      if method == "POST"
        @client.post do |req|
          req.url(path, params)
        end
      end
    end

    def compute_hmac(path, api_ts, params)
      # Support Faraday 0.9.0 forward
      # Faraday now normalizes request parameters via sorting by default but also allows
      # the params encoder to be configured by client.  It includes Faraday::NestedParamsEncoder
      # and Faraday::FlatParamsEncoder, but a 3rd party one can be provided.
      #
      # When computing the hmac, we need to normalize/sort the exact same way.

       if Faraday::VERSION == "0.8.9"
         # do it the old way
         canon_params= params.map { |k, v| "#{k.to_s}=#{v.to_s}" }.join('&')

       else  # 0.9.0+ do it the new way

         # Find out which one is in use or select default
         params_encoder = @client.options[:params_encoder] || Faraday::Utils.default_params_encoder

         # Call that params_encoder when creating signing string. Note we must unescape for BSD
         canon_params = URI.decode_www_form_component(params_encoder.encode(params))

       end
       signing_string = [@api_id, api_ts, path, canon_params].join("\n")

       OpenSSL::HMAC.hexdigest('sha1', @api_secret, signing_string)

    end

    def extended_params(path, params)
      api_ts = Time.now.utc.to_i.to_s
      extended_params = { api_ver: API_VERSION, api_id: @api_id, api_ts: api_ts }.merge(params)
      extended_params[:api_mac] = compute_hmac(path, api_ts, extended_params)
      extended_params
    end

    def set_up_resources # :doc:
       @constituents = BlueStateDigital::Constituents.new(self)
       @constituent_groups = BlueStateDigital::ConstituentGroups.new(self)
       @datasets = BlueStateDigital::Datasets.new(self)
       @dataset_maps = BlueStateDigital::DatasetMaps.new(self)
    end

    def get_deferred_results(deferred_id)
      perform_request '/get_deferred_results', {deferred_id: deferred_id}, "GET"
    end

    def retrieve_results(deferred_id)
      begin
        return get_deferred_results(deferred_id)
      rescue Faraday::Error::ClientError => e
        if e.response[:status] == 503
          return nil
        end
      end
    end

    def wait_for_deferred_result(deferred_id, timeout = 600)
      result = nil
      time_waiting = 0
      while result.nil? || (result.respond_to?(:length) && result.length == 0)
        result = retrieve_results(deferred_id)
        if result.nil? || (result.respond_to?(:length) && result.length == 0)
          time_waiting = time_waiting + 2
          if time_waiting > timeout
            raise BlueStateDigital::DeferredResultTimeout.new("exceeded timeout #{timeout} seconds waiting for #{deferred_id}")
          end
          sleep(2) 
        end
      end
      result
    end

  end
end
