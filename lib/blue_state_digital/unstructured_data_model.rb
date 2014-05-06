module BlueStateDigital
  class UnstructuredDataModel < Hash
    include Hashie::Extensions::MethodAccess
    include Hashie::Extensions::IndifferentAccess
    def initialize(hash = {})
      super
      hash.each_pair do |k,v|
        self[k] = v
      end
    end
  end
end