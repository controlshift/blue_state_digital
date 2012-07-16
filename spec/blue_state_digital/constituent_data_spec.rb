require 'spec_helper'

describe BlueStateDigital::ConstituentData do
  it "should set constituent data" do
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
    
    input = %q{<?xml version="1.0" encoding="utf-8"?>}
    input << "<api>"
    input << "<cons id=\"id\">"
    input << "<firstname>First</firstname>"
    input << "<lastname>Last</lastname>"
    input << "<is_banned>0</is_banned>"
    input << "<create_dt>#{timestamp}</create_dt>"
    input << "<cons_email>"
    input << "<email>email@email.com</email>"
    input << "<email_type>work</email_type>"
    input << "<is_subscribed>1</is_subscribed>"
    input << "<is_primary>1</is_primary>"
    input << "</cons_email>"
    input << "<cons_group id=\"3\"/>"
    input << "<cons_group id=\"5\"/>"
    input << "</cons>"
    input << "</api>"
    
    output = %q{<?xml version="1.0" encoding="utf-8"?>}
    output << "<api>"
    output << "<cons is_new='1' id='329'>"
    output << "</cons>"
    output << "</api>"
    
    BlueStateDigital::Connection.should_receive(:perform_request).with('/cons/set_constituent_data', {}, "POST", input) { output }
    
    cons_data = BlueStateDigital::ConstituentData.set(data)
    cons_data.id.should == '329'
    cons_data.is_new.should == '1'
    cons_data.is_new?.should be_true
  end
end