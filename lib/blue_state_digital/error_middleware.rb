module BlueStateDigital
  class Unauthorized < ::Faraday::Error::ClientError ; end
  class ResourceDoesNotExist < ::Faraday::Error::ClientError ; end
  class EmailNotFound < ::Faraday::Error::ClientError ; end

  class ErrorMiddleware < ::Faraday::Response::RaiseError
    def on_complete(env)
      case env[:status]
      when 404
        raise Faraday::Error::ResourceNotFound, response_values(env).to_s
      when 403
        raise BlueStateDigital::Unauthorized, response_values(env).to_s
      when 409
        if env.body =~ /does not exist/
          raise BlueStateDigital::ResourceDoesNotExist, response_values(env).to_s
        elsif env.body =~ /Email not found/
          raise BlueStateDigital::EmailNotFound, response_values(env).to_s
        else
          raise Faraday::Error::ClientError, response_values(env).to_s
        end
      when 407
        # mimic the behavior that we get with proxy requests with HTTPS
        raise Faraday::Error::ConnectionFailed, %{407 "Proxy Authentication Required "}
      when ClientErrorStatuses
        raise Faraday::Error::ClientError, response_values(env).to_s
      end
    end
  end
end