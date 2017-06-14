require 'spec_helper'

describe BlueStateDigital::Event do
  let(:time_zone) { Time.find_zone('America/New_York') }
  let(:start_date) { time_zone.now.change(usec: 0) }
  let(:end_date) { start_date + 1.hour }
  let(:event_attributes) { {event_type_id: '1', creator_cons_id: '2', name: 'event 1', description: 'my event', venue_name: 'home', venue_country: 'US', venue_zip: '10001', venue_city: 'New York', venue_state_cd: 'NY', start_date: start_date, end_date: end_date, local_timezone: 'America/New_York'} }

  describe '#to_json' do
    it "should serialize event without event_id_obfuscated" do
      event = BlueStateDigital::Event.new(event_attributes)

      event_json = JSON.parse(event.to_json)

      expect(event_json.keys).not_to include(:event_id_obfuscated)
      [:event_type_id, :creator_cons_id, :name, :description, :venue_name, :venue_country, :venue_zip, :venue_city, :venue_state_cd, :local_timezone].each do |direct_attribute|
        expect(event_json[direct_attribute.to_s]).to eq(event_attributes[direct_attribute])
      end
      expect(event_json['days'].count).to eq(1)
      start_date_serialized = event_json['days'][0]['start_datetime_system']
      expect(time_zone.parse(start_date_serialized)).to eq(start_date)
      expect(event_json['days'][0]['duration']).to eq(60)
    end

    it "should serialize event with event_id_obfuscated" do
      event_attributes[:event_id_obfuscated] = 'xyz'
      event = BlueStateDigital::Event.new(event_attributes)

      event_json = JSON.parse(event.to_json)

      [:event_id_obfuscated, :event_type_id, :creator_cons_id, :name, :description, :venue_name, :venue_country, :venue_zip, :venue_city, :venue_state_cd, :local_timezone].each do |direct_attribute|
        expect(event_json[direct_attribute.to_s]).to eq(event_attributes[direct_attribute])
      end
      expect(event_json['days'].count).to eq(1)
      start_date_serialized = event_json['days'][0]['start_datetime_system']
      expect(time_zone.parse(start_date_serialized)).to eq(start_date)
      expect(event_json['days'][0]['duration']).to eq(60)
    end
  end

  describe '#save' do
    let(:connection) { double }
    let(:event) { BlueStateDigital::Event.new(event_attributes.merge({ connection: connection })) }

    before :each do
      expect(connection)
        .to receive(:perform_request)
        .with('/event/create_event', {accept: 'application/json', event_api_version: '2', values: event.to_json}, 'POST')
        .and_return(response)
    end

    context 'successful' do
      let(:response) { '{"event_id_obfuscated":"xyz", "event_type_id":"1", "creator_cons_id":"2", "name":"event 1", "description":"my event", "venue_name":"home", "venue_zip":"10001", "venue_city":"New York", "venue_state_cd":"NY", "days":[{"start_dt":"2014-02-13 22:00:00", "duration":"180"}]}' }

      it "should perform API request and return event with event_id_obfuscated set" do
        saved_event = event.save

        expect(saved_event).not_to be_nil
        expect(saved_event.event_id_obfuscated).to eq('xyz')
      end
    end

    context 'validation error' do
      let(:response) { '{"validation_errors":{"venue_zip":["required","regex"], "name":["required"]}}' }

      it "should raise error" do
        expect { event.save }.to raise_error(BlueStateDigital::Event::EventSaveValidationException, /venue_zip.*name/m)
      end
    end
  end
end
