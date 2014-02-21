require 'spec_helper'

describe BlueStateDigital::EventRSVP do
  let(:connection) { double }

  subject { BlueStateDigital::EventRSVP.new(event_rsvp_attributes.merge({connection: connection})) }

  describe '#save' do
    let(:event_rsvp_attributes) { { event_id_obfuscated: 'xyz', will_attend: '1', email: 'john@example.com', zip: '10010', country: 'US' } }

    it "should save using Graph API" do
      connection.should_receive(:perform_graph_request).with('/addrsvp', { event_id_obfuscated: 'xyz', will_attend: '1', email: 'john@example.com', zip: '10010', country: 'US' }, 'POST')

      subject.save
    end
  end
end
