module BlueStateDigital
  class ApiDataModel
    attr_accessor :connection
    def initialize(attrs = {})
      attrs.each do |key, value|
        if self.respond_to?("#{key}=")
          self.send("#{key}=", value)
        end
      end
    end
    
    def self.get_deferred_results(deferred_id)
      connection.perform_request '/get_deferred_results', { deferred_id: deferred_id }
    end
  end
end