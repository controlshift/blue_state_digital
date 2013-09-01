require 'spec_helper'

describe BlueStateDigital::Address do
  subject { BlueStateDigital::Address.new({latitude: "40.1", longitude: "40.2"}) }
  specify { subject.latitude.should == "40.1" }
  specify { subject.longitude.should == "40.2" }

  #completely unclear why these pass.

  it "should convert address fields to_xml" do
    pending "address model is not yet used"
    subject.to_xml.should == "<xml>"
  end

  it "should return a builder" do
    pending "address model is not yet used"
    subject.to_xml.should be_a(Builder)
  end

  describe :to_hash do
    it "should return a hash of all fields" do
      attr_hash = BlueStateDigital::Address::FIELDS.inject({}) {|h,k| h[k]="#{k.to_s}_value"; h}
      phone = BlueStateDigital::Address.new attr_hash
      phone.to_hash.should == attr_hash
    end
    it "should include nil fields" do
      expected_hash = BlueStateDigital::Address::FIELDS.inject({}) {|h,k| h[k]=nil; h}
      phone = BlueStateDigital::Address.new {}
      phone.to_hash.should == expected_hash
    end
  end
end