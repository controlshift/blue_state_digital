module BlueStateDigital
  class EventType < ApiDataModel
    FIELDS = [:event_type_id, :name, :description]
    attr_accessor *FIELDS
  end

  class EventTypes < CollectionResource
    def get_event_types
      from_response(connection.perform_request('/event/get_available_types', {}, 'GET'))
    end

    private

    def from_response(response)
      parsed_response = JSON.parse(response)
      parsed_response.collect { |pet| EventType.new(pet) }
    end
  end
end
