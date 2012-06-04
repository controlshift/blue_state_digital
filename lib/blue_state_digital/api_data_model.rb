module BlueStateDigital
  class ApiDataModel
    def initialize(attrs = {})
      attrs.each do |key, value|
        if self.respond_to?("#{key}=")
          self.send("#{key}=", value)
        end
      end
    end
    
    def self.get_deferred_results(deferred_id)
      BlueStateDigital::Connection.perform_request '/get_deferred_results', { deferred_id: deferred_id }
    end
  end
end