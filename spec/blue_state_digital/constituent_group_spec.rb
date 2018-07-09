require 'spec_helper'

describe BlueStateDigital::ConstituentGroup do
  before(:each) do
    @empty_response = <<-xml_string
    <?xml version="1.0" encoding="utf-8"?>
    <api>
    </api>
    xml_string
    @empty_response.strip!

    @multiple_cons_groups = <<-xml_string
<?xml version="1.0" encoding="utf-8"?>
<api>
<cons_group id='12' modified_dt="1171861200">
    <name>First Quarter Donors</name>
    <slug>q1donors</slug>
    <description>People who donated in Q1 2007</description>
    <is_banned>0</is_banned>
    <create_dt>1168146000</create_dt>
    <group_type>manual</group_type>
    <members>162</members>
    <unique_emails>164</unique_emails>
    <unique_emails_subscribed>109</unique_emails_subscribed>
    <count_dt>1213861583</count_dt>
</cons_group>
<cons_group id='13' modified_dt="1171861200">
    <name>Second Quarter Donors</name>
    <slug>q2donors</slug>
    <description>People who donated in Q1 2007</description>
    <is_banned>0</is_banned>
    <create_dt>1168146000</create_dt>
    <group_type>manual</group_type>
    <members>162</members>
    <unique_emails>164</unique_emails>
    <unique_emails_subscribed>109</unique_emails_subscribed>
    <count_dt>1213861583</count_dt>
</cons_group>
</api>
xml_string

    @single_cons_groups = <<-xml_string
<?xml version="1.0" encoding="utf-8"?>
<api>
<cons_group id='13' modified_dt="1171861200">
    <name>First Quarter Donors</name>
    <slug>q1donors</slug>
    <description>People who donated in Q1 2007</description>
    <is_banned>0</is_banned>
    <create_dt>1168146000</create_dt>
    <group_type>manual</group_type>
    <members>162</members>
    <unique_emails>164</unique_emails>
    <unique_emails_subscribed>109</unique_emails_subscribed>
    <count_dt>1213861583</count_dt>
</cons_group>
</api>
xml_string

  end

  let(:connection) { BlueStateDigital::Connection.new({}) }

  describe ".list_constituent_groups" do
    it "should return a list of groups" do
      expect(connection).to receive(:perform_request).with('/cons_group/list_constituent_groups', {}, "GET").and_return(@multiple_cons_groups)
      groups = connection.constituent_groups.list_constituent_groups
      expect(groups).to be_a(Array)
      expect(groups.length).to eq(2)
    end
  end

  describe ".find_by_id" do
    it "should do a list comprehension to find a group in the list by id" do
      expect(connection).to receive(:perform_request).with('/cons_group/get_constituent_group', {cons_group_id: 13}, "GET").and_return(@single_cons_groups)
      group = connection.constituent_groups.find_by_id(13)
      expect(group).to be_a(BlueStateDigital::ConstituentGroup)
      expect(group.id).to eq('13')
    end

    it "should handle an empty result" do
      expect(connection).to receive(:perform_request).with('/cons_group/get_constituent_group', {cons_group_id: 13}, "GET").and_return(@empty_response)
      group = connection.constituent_groups.find_by_id(13)
      expect(group).to be_nil
    end
  end

  describe ".delete_constituent_groups" do
    it "should handle an array of integers" do
      expect(connection).to receive(:perform_request).with('/cons_group/delete_constituent_groups', {:cons_group_ids=>"2,3"}, "POST").and_return("deferred_id")
      expect(connection).to receive(:perform_request).with('/get_deferred_results', {deferred_id: "deferred_id"}, "GET").and_return(true)
      connection.constituent_groups.delete_constituent_groups([2,3])
    end

    it "should handle a single integer" do
      expect(connection).to receive(:perform_request).with('/cons_group/delete_constituent_groups', {:cons_group_ids=>"2"}, "POST").and_return("deferred_id")
      expect(connection).to receive(:perform_request).with('/get_deferred_results', {deferred_id: "deferred_id"}, "GET").and_return(true)

      connection.constituent_groups.delete_constituent_groups(2)
    end
  end

  describe ".find_or_create" do
    before(:all) do
      @timestamp = Time.now.to_i

      @new_group_xml = <<-xml_string
<?xml version="1.0" encoding="utf-8"?>
<api>
<cons_group>
<name>Environment</name>
<slug>environment</slug>
<description>Environment Group</description>
<group_type>manual</group_type>
<create_dt>#{@timestamp}</create_dt>
</cons_group>
</api>
xml_string
      @new_group_xml.gsub!(/\n/, "")

      @exists_response = <<-xml_string
<?xml version="1.0" encoding="utf-8"?>
<api>
<cons_group id='12'>
</cons_group>
</api>
xml_string
      @exists_response.strip!
    end

    it "should create a new group" do
      attrs = { name: "Environment", slug: "environment", description: "Environment Group", group_type: "manual", create_dt: @timestamp }


      expect(connection).to receive(:perform_request).with('/cons_group/get_constituent_group_by_slug', {slug:attrs[:slug]}, "GET") { @empty_response }
      expect(connection).to receive(:perform_request).with('/cons_group/add_constituent_groups', {}, "POST", @new_group_xml) { @exists_response }

      cons_group = connection.constituent_groups.find_or_create(attrs)
      expect(cons_group.id).to eq('12')
    end


    it "should not create group if it already exists" do
      attrs = { name: "Environment", slug: "environment", description: "Environment Group", group_type: "manual", create_dt: @timestamp }

      expect(connection).to receive(:perform_request).with('/cons_group/get_constituent_group_by_slug', {slug:attrs[:slug]}, "GET") { @exists_response }
      expect(connection).not_to receive(:perform_request).with('/cons_group/add_constituent_groups', {}, "POST", @new_group_xml)

      cons_group = connection.constituent_groups.find_or_create(attrs)
      expect(cons_group.id).to eq('12')
    end
  end

  describe ".from_response" do
    describe "a single group" do
      before(:each) do
        @response = <<-xml_string
    <?xml version="1.0" encoding="utf-8"?>
    <api>
    <cons_group id='12' modified_dt="1171861200">
        <name>First Quarter Donors</name>
        <slug>q1donors</slug>
        <description>People who donated in Q1 2007</description>
        <is_banned>0</is_banned>
        <create_dt>1168146000</create_dt>
        <group_type>manual</group_type>
        <members>162</members>
        <unique_emails>164</unique_emails>
        <unique_emails_subscribed>109</unique_emails_subscribed>
        <count_dt>1213861583</count_dt>
    </cons_group>
    </api>
    xml_string
      end

      it "should create a group from an xml string" do
        response = connection.constituent_groups.send(:from_response, @response)
        expect(response.id).to eq("12")
        expect(response.slug).to eq('q1donors')
      end
    end

    describe "multiple groups" do
      it "should create an array of groups from an xml string" do
        response = connection.constituent_groups.send(:from_response, @multiple_cons_groups)
        expect(response).to be_a(Array)
        first = response.first
        expect(first.id).to eq("12")
        expect(first.slug).to eq('q1donors')
      end
    end
  end

  [[:add, 'add_cons_ids_to_group'], [:remove, 'remove_cons_ids_from_group']].each do |(operation, method)|
    # operation, method = method_under_test.key, method_under_test.value

    it "should #{operation} constituent ids to group" do
      cons_group_id = "12"
      cons_ids = ["1", "2"]
      post_params = { cons_group_id: cons_group_id, cons_ids: "1,2" }

      expect(connection).to receive(:perform_request).with("/cons_group/#{method}", post_params, "POST").and_return("deferred_id")
      expect(connection).to receive(:perform_request).with('/get_deferred_results', {deferred_id: "deferred_id"}, "GET").and_return(true)

      connection.constituent_groups.send(method.to_sym, cons_group_id, cons_ids)
    end

    it "should batch on #{operation} constituent ids to group" do
      stub_const('BlueStateDigital::ConstituentGroups::CONSTITUENTS_BATCH_SIZE', 2)

      cons_group_id = "12"
      cons_ids = ["1", "2", "3", "4"]

      expect(connection).to receive(:perform_request).with("/cons_group/#{method}", { cons_group_id: cons_group_id, cons_ids: "1,2" }, "POST").and_return("deferred_id")
      expect(connection).to receive(:perform_request).with("/cons_group/#{method}", { cons_group_id: cons_group_id, cons_ids: "3,4" }, "POST").and_return("deferred_id")
      expect(connection).to receive(:perform_request).with('/get_deferred_results', {deferred_id: "deferred_id"}, "GET").twice.and_return(true)

      connection.constituent_groups.send(method.to_sym, cons_group_id, cons_ids)
    end

    it "should not wait for the result if told not to" do
      cons_group_id = "12"
      cons_ids = ["1", "2"]
      post_params = { cons_group_id: cons_group_id, cons_ids: "1,2" }

      expect(connection).to receive(:perform_request).with("/cons_group/#{method}", post_params, "POST").and_return("deferred_id")
      expect(connection).not_to receive(:perform_request).with('/get_deferred_results', {deferred_id: "deferred_id"}, "GET")

      connection.constituent_groups.send(method.to_sym, cons_group_id, cons_ids, {wait_for_result: false})
    end

    it "should #{operation} a single constituent id to a group" do
      cons_group_id = "12"
      cons_ids = ["1"]
      post_params = { cons_group_id: cons_group_id, cons_ids: "1" }

      expect(connection).to receive(:perform_request).with("/cons_group/#{method}", post_params, "POST").and_return("deferred_id")
      expect(connection).to receive(:perform_request).with('/get_deferred_results', {deferred_id: "deferred_id"}, "GET").and_return(true)

      connection.constituent_groups.send(method.to_sym, cons_group_id, cons_ids)
    end
  end


  it "should rename the constituent group" do
    expect(connection).to receive(:perform_request).with('/cons_group/rename_group', {cons_group_id: "1", new_name: "foo"}, "POST").and_return("")
    connection.constituent_groups.rename_group("1", "foo")
  end

  it "should allow replace_constituent_group!" do
    old_cons_group_id = 15
    new_cons_group_id = 1
    attrs = { name: "Environment", slug: "environment", description: "Environment Group", group_type: "manual", create_dt: @timestamp }
    new_group = double
    allow(new_group).to receive(:id).and_return(new_cons_group_id)

    old_group = double
    allow(old_group).to receive(:id).and_return(old_cons_group_id)


    expect(connection.constituent_groups).to receive(:get_constituent_group).with(old_cons_group_id).and_return( old_group )
    expect(connection.constituent_groups).to receive(:find_or_create).with(attrs).and_return( new_group )
    expect(connection.constituent_groups).to receive(:get_cons_ids_for_group).with(old_cons_group_id).and_return( [1, 2, 3] )
    expect(connection.constituent_groups).to receive(:add_cons_ids_to_group).with(new_cons_group_id, [1, 2, 3] )
    expect(connection.constituent_groups).to receive(:delete_constituent_groups).with( old_cons_group_id )

    expect(connection.constituent_groups.replace_constituent_group!(old_cons_group_id, attrs)).to eq(new_group)
  end
end
