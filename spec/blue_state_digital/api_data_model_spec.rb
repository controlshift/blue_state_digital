require 'spec_helper'

class DummyModel < BlueStateDigital::ApiDataModel
  attr_accessor :attr1, :attr2
end

describe BlueStateDigital::ApiDataModel do
  it "should initialize model with attributes" do
    model = DummyModel.new({ attr1: "1", attr2: "2" })
    expect(model.attr1).to eq("1")
    expect(model.attr2).to eq("2")
  end
end