require 'spec_helper'

describe BlueStateDigital::Event do
  let(:start_date) { Time.now }
  let(:end_date) { start_date + 1.hour }
  let(:event_attributes) { {event_type_id: '1', creator_cons_id: '2', name: 'event 1', description: 'my event', venue_name: 'home', venue_country: 'US', venue_zip: '10001', venue_city: 'New York', venue_state_cd: 'NY', start_date: start_date, end_date: end_date} }

  describe '#to_json' do
    it "should serialize event without event_id_obfuscated" do
      event = BlueStateDigital::Event.new(event_attributes)

      event_json = JSON.parse(event.to_json)

      event_json.keys.should_not include(:event_id_obfuscated)
      [:event_type_id, :creator_cons_id, :name, :description, :venue_name, :venue_country, :venue_zip, :venue_city, :venue_state_cd].each do |direct_attribute|
        event_json[direct_attribute.to_s].should == event_attributes[direct_attribute]
      end
      event_json['days'].count.should == 1
      start_date = event_json['days'][0]['start_datetime_system']
      Time.parse(start_date).should == start_date
      event_json['days'][0]['duration'].should == 60
    end

    it "should serialize event with event_id_obfuscated" do
      event_attributes[:event_id_obfuscated] = 'xyz'
      event = BlueStateDigital::Event.new(event_attributes)

      event_json = JSON.parse(event.to_json)

      [:event_id_obfuscated, :event_type_id, :creator_cons_id, :name, :description, :venue_name, :venue_country, :venue_zip, :venue_city, :venue_state_cd].each do |direct_attribute|
        event_json[direct_attribute.to_s].should == event_attributes[direct_attribute]
      end
      event_json['days'].count.should == 1
      start_date = event_json['days'][0]['start_datetime_system']
      Time.parse(start_date).should == start_date
      event_json['days'][0]['duration'].should == 60
    end
  end

  describe '#save' do
    let(:connection) { double }
    let(:event) { BlueStateDigital::Event.new(event_attributes.merge({ connection: connection })) }

    before :each do
      connection
        .should_receive(:perform_request)
        .with('/event/create_event', {accept: 'application/json', event_api_version: '2', values: event.to_json}, 'POST')
        .and_return(response)
    end

    context 'successful' do
      let(:response) { '{"event_id_obfuscated":"xyz", "event_type_id":"1", "creator_cons_id":"2", "name":"event 1", "description":"my event", "venue_name":"home", "venue_zip":"10001", "venue_city":"New York", "venue_state_cd":"NY", "days":[{"start_dt":"2014-02-13 22:00:00", "duration":"180"}]}' }

      it "should perform API request and return event with event_id_obfuscated set" do
        saved_event = event.save

        saved_event.should_not be_nil
        saved_event.event_id_obfuscated.should == 'xyz'
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
