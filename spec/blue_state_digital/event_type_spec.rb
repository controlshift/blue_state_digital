require 'spec_helper'

describe BlueStateDigital::EventType do
  subject { BlueStateDigital::EventType.new }

  it { is_expected.to respond_to(:event_type_id) }
  it { is_expected.to respond_to(:event_type_id=) }
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:name=) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:description=) }
end

describe BlueStateDigital::EventTypes do
  let(:connection) { BlueStateDigital::Connection.new({}) }

  let(:single_event_types_response) { fixture('single_event_type.json').read }
  let(:multiple_event_types_response) { fixture('multiple_event_types.json').read }

  subject { BlueStateDigital::EventTypes.new(connection) }

  it "should retrieve single event type" do
    expect(connection).to receive(:perform_request).with('/event/get_available_types', {}, 'GET').and_return(single_event_types_response)

    event_types = subject.get_event_types

    expect(event_types.count).to eq(1)
    expect(event_types.first.event_type_id).to eq('1')
    expect(event_types.first.name).to eq("My event type")
    expect(event_types.first.description).to eq("An event type for testing")
  end

  it "should retrieve multiple event types" do
    expect(connection).to receive(:perform_request).with('/event/get_available_types', {}, 'GET').and_return(multiple_event_types_response)

    event_types = subject.get_event_types

    expect(event_types.count).to eq(2)
    verify_event_type_existence(event_types, {id: '1', name: 'My first event type', description: 'An event type for testing'})
    verify_event_type_existence(event_types, {id: '2', name: 'My second event type', description: 'Another event type for testing'})
  end

  def verify_event_type_existence(event_types, expected_event_type_attributes)
    expected_event_type_attributes.each do |attr, value|
      unless attr == :id
        val = event_types.any?{ |et| et.send(attr) == value }
        expect(val).to be_truthy
      end
    end
  end
end
