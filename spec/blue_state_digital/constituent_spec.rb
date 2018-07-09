require 'spec_helper'

describe BlueStateDigital::Constituent do
  describe ".to_xml" do
    before(:each) do
      @cons = BlueStateDigital::Constituent.new({})
    end

    context "with addresses" do
      let(:expected_result) do
        <<-xml_string.split("\n").map(&:strip).join
          <?xml version="1.0" encoding="utf-8"?>
          <api>
            <cons>
              <cons_addr>
                <addr1>one</addr1>
              </cons_addr>
            </cons>
          </api>
        xml_string
      end
      it "should allow constituent addresses entries as hashes" do 
        constituent = BlueStateDigital::Constituent.new addresses: [{addr1: 'one'}] 
        expect(constituent.to_xml).to eq(expected_result)
      end
      it "should allow constituent addresses entries as BlueStateDigital::Addresses" do 
        constituent = BlueStateDigital::Constituent.new addresses: [BlueStateDigital::Address.new(addr1: 'one')] 
        expect(constituent.to_xml).to eq(expected_result)
      end

    end

    context "with emails" do
      let(:expected_result) do
        <<-xml_string.split("\n").map(&:strip).join
          <?xml version="1.0" encoding="utf-8"?>
          <api>
            <cons>
              <cons_email>
                <email>one@two.com</email>
              </cons_email>
            </cons>
          </api>
        xml_string
      end
      it "should allow constituent addresses entries as hashes" do 
        constituent = BlueStateDigital::Constituent.new emails: [{email: 'one@two.com'}] 
        expect(constituent.to_xml).to eq(expected_result)
      end
      it "should allow constituent addresses entries as BlueStateDigital::Addresses" do 
        constituent = BlueStateDigital::Constituent.new emails: [BlueStateDigital::Email.new(email: 'one@two.com')] 
        expect(constituent.to_xml).to eq(expected_result)
      end

    end

    context "with phone numbers" do
      let(:expected_result) do
        <<-xml_string.split("\n").map(&:strip).join
          <?xml version="1.0" encoding="utf-8"?>
          <api>
            <cons>
              <cons_phone>
                <phone>123321123</phone>
              </cons_phone>
            </cons>
          </api>
        xml_string
      end
      it "should allow constituent addresses entries as hashes" do 
        constituent = BlueStateDigital::Constituent.new phones: [{phone: '123321123'}] 
        expect(constituent.to_xml).to eq(expected_result)
      end
      it "should allow constituent addresses entries as BlueStateDigital::Addresses" do 
        constituent = BlueStateDigital::Constituent.new phones: [BlueStateDigital::Phone.new(phone: '123321123')] 
        expect(constituent.to_xml).to eq(expected_result)
      end

    end

    [:firstname,:lastname,:is_banned,:create_dt,:birth_dt,:gender].each do |param|
      describe "with #{param}" do
        let (:expected_result) do
          <<-xml_string.split("\n").map(&:strip).join
            <?xml version="1.0" encoding="utf-8"?>
            <api>
              <cons>
                <#{param.to_s}>#{param.to_s}_value</#{param.to_s}>
              </cons>
            </api>
          xml_string
        end
        it "should be present as #{param.to_s} tag in cons tag" do
          constituent = BlueStateDigital::Constituent.new 
          eval("constituent.#{param.to_s}='#{param.to_s}_value'")
          expect(constituent.to_xml).to eq(expected_result)
        end 

      end
    end
  end

  let(:connection) { BlueStateDigital::Connection.new({}) }

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

      @constituent_with_addr = <<-xml_string
      <?xml version="1.0" encoding="utf-8"?>
      <api>
      <cons id="4382" modified_dt="1171861200">
          <guid>ygdFPkyEdomzBhWEFZGREys</guid>
          <firstname>Bob</firstname>
          <lastname>Smith</lastname>
          <has_account>1</has_account>
          <is_banned>0</is_banned>
          <create_dt>1168146000</create_dt>
          <cons_addr id="43" modified_dt="1355800948">
            <addr1>yyy2</addr1>
            <addr2>yyy3</addr2>
            <city>here</city>
            <state_cd>2323</state_cd>
            <zip>00323</zip>
            <country></country>
            <latitude>0.000000</latitude>
            <longitude>0.000000</longitude>
            <is_primary>0</is_primary>
            <cons_addr_type_id>0</cons_addr_type_id>
          </cons_addr>
          <cons_addr id="42" modified_dt="1355800946">
            <addr1>xxx1</addr1>
            <addr2>xxx2</addr2>
            <city>Helsinki</city>
            <state_cd></state_cd>
            <zip>12345</zip>
            <country>AM</country>
            <latitude>42.810059</latitude>
            <longitude>-73.951050</longitude>
            <is_primary>1</is_primary>
            <cons_addr_type_id>0</cons_addr_type_id>
          </cons_addr>
      </cons>
      </api>
      xml_string

      @constituent_with_emails = <<-xml_string
      <?xml version="1.0" encoding="utf-8"?>
      <api>
      <cons id="4382" modified_dt="1171861200">
          <guid>ygdFPkyEdomzBhWEFZGREys</guid>
          <firstname>Bob</firstname>
          <lastname>Smith</lastname>
          <has_account>1</has_account>
          <is_banned>0</is_banned>
          <create_dt>1168146000</create_dt>

          <cons_email id="35" modified_dt="1355796381">
            <email>gil+punky1@thoughtworks.com</email>
            <email_type>personal</email_type>
            <is_subscribed>1</is_subscribed>
            <is_primary>1</is_primary>
          </cons_email>
          <cons_email id="36" modified_dt="1355796381">
            <email>fred@thoughtworks.com</email>
            <email_type>internal</email_type>
            <is_subscribed>0</is_subscribed>
            <is_primary>0</is_primary>
          </cons_email>
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
        expect(connection).to receive(:perform_request).with('/cons/get_constituents_by_email', {:emails=>"george@washington.com", :bundles => 'cons_group'}, "GET").and_return(@single_constituent)
        response = connection.constituents.get_constituents_by_email("george@washington.com").first
        expect(response.id).to eq("4382")
        expect(response.firstname).to eq('Bob')
      end

      it "should return constituents' details based on bundles" do
        bundles = 'cons_addr'
        expect(connection).to receive(:perform_request).with('/cons/get_constituents_by_email', {:emails=>"george@washington.com", :bundles => bundles}, "GET").and_return(@constituent_with_addr)
        response = connection.constituents.get_constituents_by_email("george@washington.com", ['cons_addr']).first
        response.addresses[0].addr1 == "aaa1"
        response.addresses[0].addr2 == "aaa2"
      end
    end

    describe ".get_constituents_by_id" do
      it "should return a constituent" do
        expect(connection).to receive(:perform_request).with('/cons/get_constituents_by_id', {:cons_ids=>"23", :bundles => 'cons_group'}, "GET").and_return(@single_constituent)
        response = connection.constituents.get_constituents_by_id("23").first
        expect(response.id).to eq("4382")
        expect(response.firstname).to eq('Bob')
      end
    end

    describe ".from_response" do
      it "should set connection in generated constituents" do
        response = connection.constituents.send(:from_response, @single_constituent)
        expect(response).to be_a(Array)
        expect(response.size).to eq(1)
        expect(response.first.connection).to eq(connection)
      end

      it "should create an array of constituents from a response that contains multiple constituents" do
        response = connection.constituents.send(:from_response, @multiple_constituents)
        expect(response).to be_a(Array)
        first = response.first
        expect(first.id).to eq("4382")
        expect(first.firstname).to eq('Bob')
      end

      it "should create an array of single constituent when only one is supplied" do
        response = connection.constituents.send(:from_response, @single_constituent)
        expect(response).to be_a(Array)
        expect(response.size).to eq(1)
        expect(response.first.id).to eq("4382")
        expect(response.first.firstname).to eq('Bob')
        expect(response.first.gender).to eq('M')
      end

      it "should handle constituent group membership" do
        response = connection.constituents.send(:from_response, @constituent_with_groups).first
        expect(response.id).to eq('4382')
        expect(response.group_ids).to eq(["17", "41"])
      end

      it "should handle single constituent group membership" do
        response = connection.constituents.send(:from_response, @constituent_with_group).first
        expect(response.id).to eq('4382')
        expect(response.group_ids).to eq(["41"])
      end

      it "Should handle constituent addresses" do
        response = connection.constituents.send(:from_response, @constituent_with_addr).first
        expect(response.addresses.size).to eq(2)
        expect(response.addresses[0]).to be_a BlueStateDigital::Address
        expect(response.addresses[0].addr1).to eq("yyy2")
        expect(response.addresses[0].addr2).to eq("yyy3")

        expect(response.addresses[1]).to be_a BlueStateDigital::Address
        expect(response.addresses[1].addr1).to eq("xxx1")
        expect(response.addresses[1].addr2).to eq("xxx2")
      end

      it "Should handle constituent email addresses" do
        response = connection.constituents.send(:from_response, @constituent_with_emails).first
        expect(response.emails.size).to eq(2)
        expect(response.emails[0]).to be_a BlueStateDigital::Email
        expect(response.emails[0].email).to eq("gil+punky1@thoughtworks.com")
        expect(response.emails[0].email_type).to eq("personal")
        expect(response.emails[0].is_subscribed).to eq("1")
        expect(response.emails[0].is_primary).to eq("1")

        expect(response.emails[1]).to be_a BlueStateDigital::Email
        expect(response.emails[1].email).to eq("fred@thoughtworks.com")
        expect(response.emails[1].email_type).to eq("internal")
        expect(response.emails[1].is_subscribed).to eq("0")
        expect(response.emails[1].is_primary).to eq("0")
      end

    end
  end

  describe "delete_constituents_by_id" do
    it "should handle an array of integers" do
      expect(connection).to receive(:perform_request).with('/cons/delete_constituents_by_id', {:cons_ids=>"2,3"}, "POST")
      connection.constituents.delete_constituents_by_id([2,3])
    end

    it "should handle a single integer" do
      expect(connection).to receive(:perform_request).with('/cons/delete_constituents_by_id', {:cons_ids=>"2"}, "POST")
      connection.constituents.delete_constituents_by_id(2)
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
      groups: [3, 5],
      connection: connection
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

    expect(connection).to receive(:perform_request).with('/cons/upsert_constituent_data', {}, "POST", input) { output }

    cons_data = BlueStateDigital::Constituent.new(data)
    cons_data.save
    expect(cons_data.id).to eq('329')
    expect(cons_data.is_new).to eq('1')
    expect(cons_data.is_new?).to be_truthy
  end

  describe "#to_xml" do
    it "should convert a constituent hash to xml" do
      cons = BlueStateDigital::Constituent.new ({
          firstname: 'George',
          lastname: 'Washington',
          create_dt: Time.now.to_i,
          emails: [{ email: 'george@washington.com', is_subscribed: 1}],
          addresses: [{ country: 'US', zip: '20001', is_primary: 1}],
          phones: [{phone: '123456789', phone_type: 'unknown'}]
      })
      expect(cons.to_xml).not_to be_nil
    end
  end
end
