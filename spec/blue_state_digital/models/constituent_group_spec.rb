require 'spec_helper'
require 'blue_state_digital/models/constituent_group'

describe BlueStateDigital::Models::ConstituentGroup do
  it "#to_xml" do
    timestamp = Time.now
    attrs = { name: "Environment", slug: "environment", description: "Environment Group", group_type: "manual", created_at: timestamp }
    
    xml_data = %q{<?xml version="1.0" encoding="utf-8"?>}
    xml_data << "<api>"
    xml_data << "<cons_group>"
    xml_data << "<name>Environment</name>"
    xml_data << "<slug>environment</slug>"
    xml_data << "<description>Environment Group</description>"
    xml_data << "<group_type>manual</group_type>"
    xml_data << "<create_dt>#{timestamp.utc.to_i}</create_dt>"
    xml_data << "</cons_group>"
    xml_data << "</api>"
    
    BlueStateDigital::Models::ConstituentGroup.new(attrs).to_xml.should == xml_data
  end
end