module BlueStateDigital
  class EventRSVP < ApiDataModel
    FIELDS = [:event_id_obfuscated, :will_attend, :cons_id]
    attr_accessor *FIELDS

    def save
      connection.perform_graph_request '/rsvp/add', self.attributes, "POST"
    end

    def attributes
      FIELDS.inject({}) do |attrs, field|
        attrs[field] = self.send(field)
        attrs
      end
    end
  end
end
