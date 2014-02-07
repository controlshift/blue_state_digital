module BlueStateDigital
  class Event < ApiDataModel
    FIELDS = [:event_id_obfuscated, :event_type_id, :creator_cons_id, :name, :description, :venue_name, :venue_zip, :venue_city, :venue_state_cd, :start_date, :end_date]
    attr_accessor *FIELDS

    def save
      json_text = connection.perform_request '/event/create_event', {accept: 'application/json', event_api_version: '2', values: self.to_json}, "POST"
      JSON.parse(json_text)
    end

    def to_json
      event_attrs = self.event_id_obfuscated.blank? ? { } : { event_id_obfuscated: self.event_id_obfuscated }
      (FIELDS - [:event_id_obfuscated, :start_date, :end_date]).each do |field|
        event_attrs[field] = self.send(field)
      end

      duration_in_minutes = ((end_date - start_date) / 60).to_i
      day_attrs = { start_datetime_system: start_date.strftime('%Y-%m-%d %H:%M:%S %z'), duration: duration_in_minutes }
      event_attrs[:days] = [ day_attrs ]

      event_attrs.to_json
    end
  end
end
