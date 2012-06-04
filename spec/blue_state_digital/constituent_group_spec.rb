require 'spec_helper'

describe BlueStateDigital::ConstituentGroup do
  it "should create constituent group" do
    timestamp = Time.now.to_i
    attrs = { name: "Environment", slug: "environment", description: "Environment Group", group_type: "manual", create_dt: timestamp }
    
    input = %q{<?xml version="1.0" encoding="utf-8"?>}
    input << "<api>"
    input << "<cons_group>"
    input << "<name>Environment</name>"
    input << "<slug>environment</slug>"
    input << "<description>Environment Group</description>"
    input << "<group_type>manual</group_type>"
    input << "<create_dt>#{timestamp}</create_dt>"
    input << "</cons_group>"
    input << "</api>"
    
    output = %q{<?xml version="1.0" encoding="utf-8"?>}
    output << "<api>"
    output << "<cons_group id='12'>"
    output << "</cons_group>"
    output << "</api>"
    
    BlueStateDigital::Connection.should_receive(:perform_request).with('/cons_group/add_constituent_groups', {}, "POST", input) { output }
    
    cons_group = BlueStateDigital::ConstituentGroup.create(attrs)
    cons_group.id.should == '12'
  end
  
  it "should add constituent ids to group" do
    cons_group_id = "12"
    cons_ids = ["1", "2"]
    post_params = { cons_group_id: cons_group_id, cons_ids: "1,2" }
    
    BlueStateDigital::Connection.should_receive(:perform_request).with('/cons_group/add_cons_ids_to_group', post_params, "POST")
    
    BlueStateDigital::ConstituentGroup.add_cons_ids_to_group(cons_group_id, cons_ids)
  end
end