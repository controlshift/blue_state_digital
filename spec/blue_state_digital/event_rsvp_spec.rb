require 'spec_helper'

describe BlueStateDigital::EventRSVP do
  let(:connection) { double }

  subject { BlueStateDigital::EventRSVP.new(event_rsvp_attributes.merge({connection: connection})) }

  describe '#save' do
    let(:event_rsvp_attributes) { { event_id: '1', will_attend: '1', cons_id: '99' } }

    it "should save using Graph API" do
      connection.should_receive(:perform_graph_request).with('/rsvp/add', { event_id: '1', will_attend: '1', cons_id: '99' }, 'POST')

      subject.save
    end
  end
end
