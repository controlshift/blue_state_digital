require 'spec_helper'

class DummyModel < BlueStateDigital::ApiDataModel
  attr_accessor :attr1, :attr2
end

describe BlueStateDigital::ApiDataModel do
  it "should initialize model with attributes" do
    model = DummyModel.new({ attr1: "1", attr2: "2" })
    model.attr1.should == "1"
    model.attr2.should == "2"
  end
end