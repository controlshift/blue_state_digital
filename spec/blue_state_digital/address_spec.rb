require 'spec_helper'

describe BlueStateDigital::Address do
  subject { BlueStateDigital::Address.new({latitude: "40.1", longitude: "40.2"}) }
  specify { expect(subject.latitude).to eq("40.1") }
  specify { expect(subject.longitude).to eq("40.2") }


  it "should return a builder" do
    expect(subject.to_xml).to be_a(Builder)
  end

  describe :to_hash do
    it "should return a hash of all fields" do
      attr_hash = BlueStateDigital::Address::FIELDS.inject({}) {|h,k| h[k]="#{k.to_s}_value"; h}
      phone = BlueStateDigital::Address.new attr_hash
      expect(phone.to_hash).to eq(attr_hash)
    end
    it "should include nil fields" do
      expected_hash = BlueStateDigital::Address::FIELDS.inject({}) {|h,k| h[k]=nil; h}
      phone = BlueStateDigital::Address.new {}
      expect(phone.to_hash).to eq(expected_hash)
    end
  end
end