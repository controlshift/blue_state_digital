require 'spec_helper'
require 'blue_state_digital/constituent_data_builder'

describe BlueStateDigital::ConstituentDataBuilder do
  it "should convert hash to corresponding xml data" do
    timestamp = Time.now
    
    data = { 
      id: 'id', 
      first_name: 'First', 
      last_name: 'Last', 
      is_banned: false, 
      created_at: timestamp,
      emails: [{ email: "email@email.com", email_type: "work", is_subscribed: true, is_primary: true }]
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
    xml_data << "</cons>"
    xml_data << "</api>"
    
    BlueStateDigital::ConstituentDataBuilder.from_hash(data).should == xml_data
  end
end