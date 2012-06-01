require 'spec_helper'
require 'blue_state_digital/models/constituent_data'

describe BlueStateDigital::Models::ConstituentData do
  it "#to_xml" do
    timestamp = Time.now
    
    data = { 
      id: 'id', 
      first_name: 'First', 
      last_name: 'Last', 
      is_banned: false, 
      created_at: timestamp,
      emails: [{ email: "email@email.com", email_type: "work", is_subscribed: true, is_primary: true }],
      group_ids: [3, 5]
    }
    
    xml_data = %q{<?xml version="1.0" encoding="utf-8"?>}
    xml_data << "<api>"
    xml_data << "<cons id=\"id\">"
    xml_data << "<firstname>First</firstname>"
    xml_data << "<lastname>Last</lastname>"
    xml_data << "<is_banned>0</is_banned>"
    xml_data << "<create_dt>#{timestamp.utc.to_i}</create_dt>"
    xml_data << "<cons_email>"
    xml_data << "<email>email@email.com</email>"
    xml_data << "<email_type>work</email_type>"
    xml_data << "<is_subscribed>1</is_subscribed>"
    xml_data << "<is_primary>1</is_primary>"
    xml_data << "</cons_email>"
    xml_data << "<cons_group id=\"3\"/>"
    xml_data << "<cons_group id=\"5\"/>"
    xml_data << "</cons>"
    xml_data << "</api>"
    
    BlueStateDigital::Models::ConstituentData.new(data).to_xml.should == xml_data
  end
end