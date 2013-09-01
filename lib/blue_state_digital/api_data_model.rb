module BlueStateDigital
  class ApiDataModel
    FIELD = nil

    attr_accessor :connection
    def initialize(attrs = {})
      attrs.each do |key, value|
        if self.respond_to?("#{key}=")
          self.send("#{key}=", value)
        end
      end
    end

    def to_hash
      self.class::FIELDS.inject({}) {|h, key| h[key] = self.send(key); h}
    end

  end
end