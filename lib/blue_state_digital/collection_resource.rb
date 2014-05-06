module BlueStateDigital
  class CollectionResource
  	class NoConnectionException < StandardError
      def initialize
        super("No connection available")
      end
    end
  	class FetchFailureException < StandardError
  	  def initialize(msg)
        super
      end
  	end
    attr_accessor :connection

    def initialize(connection)
      self.connection = connection
    end
  end
end