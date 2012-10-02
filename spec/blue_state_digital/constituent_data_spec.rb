require 'spec_helper'

describe BlueStateDigital::ConstituentData do

  describe "Get Constituents" do
    before(:each) do
      @single_constituent = <<-xml_string
      <?xml version="1.0" encoding="utf-8"?>
      <api>
      <cons id="4382" modified_dt="1171861200">
          <guid>ygdFPkyEdomzBhWEFZGREys</guid>
          <firstname>Bob</firstname>
          <middlename>Reginald</middlename>
          <lastname>Smith</lastname>
          <has_account>1</has_account>
          <is_banned>0</is_banned>
          <create_dt>1168146000</create_dt>
          <suffix>III</suffix>
          <prefix>Mr</prefix>
          <gender>M</gender>
      </cons>
      </api>
      xml_string
      
      @constituent_with_group = <<-xml_string
      <?xml version="1.0" encoding="utf-8"?>
      <api>
      <cons id="4382" modified_dt="1171861200">
          <guid>ygdFPkyEdomzBhWEFZGREys</guid>
          <firstname>Bob</firstname>
          <lastname>Smith</lastname>
          <has_account>1</has_account>
          <is_banned>0</is_banned>
          <create_dt>1168146000</create_dt>

          <cons_group id="41" modified_dt="1163196031" />
      </cons>
      </api>
      xml_string
      
      @constituent_with_groups = <<-xml_string
      <?xml version="1.0" encoding="utf-8"?>
      <api>
      <cons id="4382" modified_dt="1171861200">
          <guid>ygdFPkyEdomzBhWEFZGREys</guid>
          <firstname>Bob</firstname>
          <lastname>Smith</lastname>
          <has_account>1</has_account>
          <is_banned>0</is_banned>
          <create_dt>1168146000</create_dt>

          <cons_group id="17"  modified_dt="1168146011"/>
          <cons_group id="41" modified_dt="1163196031" />
      </cons>
      </api>
      xml_string
      
      @multiple_constituents = <<-xml_string
      <?xml version="1.0" encoding="utf-8"?>
      <api>
      <cons id="4382" modified_dt="1171861200">
          <guid>ygdFPkyEdomzBhWEFZGREys</guid>
          <firstname>Bob</firstname>
          <middlename>Reginald</middlename>
          <lastname>Smith</lastname>
          <has_account>1</has_account>
          <is_banned>0</is_banned>
          <create_dt>1168146000</create_dt>
          <suffix>III</suffix>
          <prefix>Mr</prefix>
          <gender>M</gender>
      </cons>
      
      <cons id="4381" modified_dt="1171861200">
          <guid>ygdFPkyEdomzBhWEFZGREys</guid>
          <firstname>Susan</firstname>
          <middlename>Reginald</middlename>
          <lastname>Smith</lastname>
          <has_account>1</has_account>
          <is_banned>0</is_banned>
          <create_dt>1168146000</create_dt>
          <suffix></suffix>
          <prefix>Mrs</prefix>
          <gender>F</gender>
      </cons>
      </api>
      xml_string
    end
    describe ".get_constituents_by_email" do
      it "should make a filtered constituents query" do
        BlueStateDigital::Connection.should_receive(:perform_request).with('/cons/get_constituents', {:filter=>"email=george@washington.com", :bundles => 'cons_group'}, "GET").and_return("deferred_id")
        BlueStateDigital::Connection.should_receive(:perform_request).with('/get_deferred_results', {deferred_id: "deferred_id"}, "GET").and_return(@single_constituent)
        response = BlueStateDigital::ConstituentData.get_constituents_by_email("george@washington.com")
        response.id.should == "4382"
        response.firstname.should == 'Bob'
      end
    end

    describe ".from_response" do
      it "should create an array of constituents from a response that contains multiple constituents" do
        response = BlueStateDigital::ConstituentData.send(:from_response, @multiple_constituents)
        response.should be_a(Array)
        first = response.first
        first.id.should == "4382"
        first.firstname.should == 'Bob'
      end

      it "should create a single constituent when only one is supplied" do
        response = BlueStateDigital::ConstituentData.send(:from_response, @single_constituent)
        response.id.should == "4382"
        response.firstname.should == 'Bob'
      end
      
      it "should handle constituent group membership" do
        response = BlueStateDigital::ConstituentData.send(:from_response, @constituent_with_groups)
        response.id.should == '4382'
        response.group_ids.should == ["17", "41"]
      end
      
      it "should handle single constituent group membership" do
        response = BlueStateDigital::ConstituentData.send(:from_response, @constituent_with_group)
        response.id.should == '4382'
        response.group_ids.should == ["41"]
      end
    end
  end
  
  describe "delete_constituents_by_id" do
    it "should handle an array of integers" do
      BlueStateDigital::Connection.should_receive(:perform_request).with('/cons/delete_constituents_by_id', {:cons_ids=>"2,3"}, "POST")
      BlueStateDigital::ConstituentData.delete_constituents_by_id([2,3])
    end

    it "should handle a single integer" do
      BlueStateDigital::Connection.should_receive(:perform_request).with('/cons/delete_constituents_by_id', {:cons_ids=>"2"}, "POST")
      BlueStateDigital::ConstituentData.delete_constituents_by_id(2)
    end
  end
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