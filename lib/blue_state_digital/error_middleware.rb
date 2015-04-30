module BlueStateDigital
  class Unauthorized < ::Faraday::Error::ClientError ; end
  class ErrorMiddleware < ::Faraday::Response::RaiseError
    def on_complete(env)
      case env[:status]
      when 404
        raise Faraday::Error::ResourceNotFound, response_values(env)
      when 403
        raise BlueStateDigital::Unauthorized, response_values(env)  
      when 407
        # mimic the behavior that we get with proxy requests with HTTPS
        raise Faraday::Error::ConnectionFailed, %{407 "Proxy Authentication Required "}
      when ClientErrorStatuses
        raise Faraday::Error::ClientError, response_values(env)
      end
    end
  end
end