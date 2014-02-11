module BlueStateDigital
  class Event < ApiDataModel

    class EventSaveValidationException < StandardError
      def initialize(validation_errors)
        error_message = ""
        validation_errors.each { |field, errors| error_message << "Validation errors on field #{field}: #{errors}\n" }

        super(error_message)
      end
    end

    FIELDS = [:event_id_obfuscated, :event_type_id, :creator_cons_id, :name, :description, :venue_name, :venue_zip, :venue_city, :venue_state_cd, :start_date, :end_date]
    attr_accessor *FIELDS

    def save
      if self.event_id_obfuscated.blank?
        response_json_text = connection.perform_request '/event/create_event', {accept: 'application/json', event_api_version: '2', values: self.to_json}, "POST"
      else
        response_json_text = connection.perform_request '/event/update_event', {accept: 'application/json', event_api_version: '2', values: self.to_json}, "POST"
      end

      response = JSON.parse(response_json_text)
      if response['validation_errors']
        raise EventSaveValidationException, response['validation_errors']
      else
        self.event_id_obfuscated = response['event_id_obfuscated']
      end

      self
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
