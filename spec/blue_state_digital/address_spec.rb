require 'spec_helper'

describe BlueStateDigital::Address do
  subject { BlueStateDigital::Address.new({latitude: "40.1", longitude: "40.2"}) }
  specify { subject.latitude.should == "40.1" }
  specify { subject.longitude.should == "40.2" }

  #completely unclear why these pass.

  it "should convert address fields to_xml" do
    subject.to_xml.should == "<xml>"
  end

  it "should return a builder" do
    subject.to_xml.should be_a(Builder)
  end
end