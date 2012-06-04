require 'spec_helper'

describe BlueStateDigital::ConstituentData do
  it "#set" do
    timestamp = Time.now.to_i
    
    data = { 
      id: 'id', 
      firstname: 'First', 
      lastname: 'Last', 
      is_banned: 0, 
      create_dt: timestamp,
      emails: [{ email: "email@email.com", email_type: "work", is_subscribed: 1, is_primary: 1 }],
      groups: [3, 5]
    }
    
    xml_data = %q{<?xml version="1.0" encoding="utf-8"?>}
    xml_data << "<api>"
    xml_data << "<cons id=\"id\">"
    xml_data << "<firstname>First</firstname>"
    xml_data << "<lastname>Last</lastname>"
    xml_data << "<is_banned>0</is_banned>"
    xml_data << "<create_dt>#{timestamp}</create_dt>"
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
    
    BlueStateDigital::Connection.should_receive(:perform_request).with('/cons/set_constituent_data', {}, "POST", xml_data)
    
    BlueStateDigital::ConstituentData.set(data)
  end
end