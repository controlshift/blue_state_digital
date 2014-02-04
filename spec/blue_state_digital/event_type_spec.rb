require 'spec_helper'

describe BlueStateDigital::EventType do
  subject { BlueStateDigital::EventType.new }

  it { should respond_to(:event_type_id) }
  it { should respond_to(:event_type_id=) }
  it { should respond_to(:name) }
  it { should respond_to(:name=) }
  it { should respond_to(:description) }
  it { should respond_to(:description=) }
end

describe BlueStateDigital::EventTypes do
  let(:connection) { BlueStateDigital::Connection.new({}) }

  let(:single_event_types_response) { fixture('single_event_type.json').read }
  let(:multiple_event_types_response) { fixture('multiple_event_types.json').read }

  subject { BlueStateDigital::EventTypes.new(connection) }

  it "should retrieve single event type" do
    connection.should_receive(:perform_request).with('/event/get_available_types', {}, 'GET').and_return(single_event_types_response)

    event_types = subject.get_event_types

    event_types.count.should == 1
    event_types.first.event_type_id.should == '1'
    event_types.first.name.should == "My event type"
    event_types.first.description.should == "An event type for testing"
  end

  it "should retrieve multiple event types" do
    connection.should_receive(:perform_request).with('/event/get_available_types', {}, 'GET').and_return(multiple_event_types_response)

    event_types = subject.get_event_types

    event_types.count.should == 2
    verify_event_type_existence(event_types, {id: '1', name: 'My first event type', description: 'An event type for testing'})
    verify_event_type_existence(event_types, {id: '2', name: 'My second event type', description: 'Another event type for testing'})
  end

  def verify_event_type_existence(event_types, expected_event_type_attributes)
    expected_event_type_attributes.each do |attr, value|
      expect { event_types.any? { |et| et.send(attr) == value } }.to be_true
    end
  end
end