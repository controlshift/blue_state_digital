module BlueStateDigital
  class Connection
    API_VERSION = 1
    API_BASE = '/page/api'
    GRAPH_API_BASE = '/page/graph'

    attr_reader :constituents, :constituent_groups, :contributions

    def initialize(params = {})
      @api_id = params[:api_id]
      @api_secret = params[:api_secret]
      @client = Faraday.new(:url => "https://#{params[:host]}/") do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter(params[:adapter] || Faraday.default_adapter)  # make requests with Net::HTTP by default
      end
      set_up_resources
    end

    def perform_request(call, params = {}, method = "GET", body = nil)
      path = API_BASE + call
      if method == "POST"
        @client.post do |req|
          content_type = params.delete(:content_type) || 'application/x-www-form-urlencoded'
          accept = params.delete(:accept) || 'text/xml'
          req.url("#{path}?#{extended_params(path, params).to_query}")
          req.body = body
          req.headers['Content-Type'] = content_type
          req.headers['Accept'] = accept
        end.body
      else
        @client.get("#{path}?#{extended_params(path, params).to_query}").body
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
      signing_string = [@api_id, api_ts, path, URI.unescape(params.to_query)].join("\n")
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
       @contributions = BlueStateDigital::Contributions.new(self)
    end

    def get_deferred_results(deferred_id)
      perform_request '/get_deferred_results', {deferred_id: deferred_id}, "GET"
    end

    def retrieve_results(deferred_id)
      begin
        return get_deferred_results(deferred_id)
      rescue RestClient::Exception => e
        if e.http_code == 503
          return nil
        end
      end
    end

    def wait_for_deferred_result(deferred_id)
      result = nil
      while result.nil?
        result = retrieve_results(deferred_id)
        sleep(2) if result.nil?
      end
      result
    end

  end
end