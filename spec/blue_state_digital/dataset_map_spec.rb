require 'spec_helper'

describe BlueStateDigital::DatasetMap do

  let(:connection) { double }
  let(:dataset_map_attributes) do
    {
    }
  end
  subject { BlueStateDigital::DatasetMap.new(dataset_map_attributes.merge({connection: connection}))}

  describe "new" do
    it "should accept dataset_map params" do
      dataset = BlueStateDigital::Dataset.new(dataset_map_attributes)
      dataset_map_attributes.each do |k,v|
        dataset.send(k).should == v
      end
    end
  end

  describe "save" do
    context "validations" do
      it "should not error if there is no data" do
        subject.data.should be_blank
        subject.should be_valid
      end
      it "should error if there is data but no data header" do
        subject.add_data_row([1])
        subject.should_not be_valid
        subject.errors.full_messages.should == ["data_header is missing"]
      end
    end
    context "csv upload" do
      let(:header) { ['a','b','c','d'] }
      let(:row1) { ['1','2','3','4'] }
      let(:csv) { "#{header.join(',')}\n#{row1.join(',')}\n"}
      before(:each) do
        connection
          .should_receive(:perform_request_raw)
          .with('/cons/upload_dataset_map', {api_ver: 2, content_type: "text/csv"}, 'POST',csv)
          .and_return(response)
      end
      let(:response) { Hashie::Mash.new(status: 200,body: "successful") }
      it "should convert data into csv and dispatch" do
        subject.add_data_header(header)
        subject.add_data_row(row1)
        subject.save.should be_true
      end
      context "failure" do
        let(:response) { Hashie::Mash.new(status: 404,body: "Something bad happened") }
        it "should return false if save fails" do
          subject.add_data_header(header)
          subject.add_data_row(row1)
          subject.save.should be_false
        end
      end
    end
  end

  describe "delete" do
    context "validations" do
      it "should complaing if map_id is not provided" do
        subject.map_id = nil
        subject.delete.should be false
        subject.errors.full_messages.should == ["map_id is missing"]
      end
    end
    context "service" do
      let(:map_id) { 1 }
      let(:delete_payload){ {map_id: map_id} }
      before :each do
        connection
          .should_receive(:perform_request_raw)
          .with('/cons/delete_dataset_map', {api_ver: 2}, 'POST',delete_payload.to_json)
          .and_return(response)
      end
      context "failure" do
        let(:response) { Hashie::Mash.new(status: 404,body: "Something bad happened") }
        it "should return false if delete fails" do
          subject.map_id = map_id
          subject.delete.should be_false
          subject.errors.full_messages.should == ["web_service Something bad happened"]
        end
      end
      context "success" do
        let(:response) { Hashie::Mash.new(status: 200,body: "") }
        it "should return true" do
          subject.map_id = map_id
          subject.delete.should be_true
          subject.errors.full_messages.should == []
        end
      end
    end
  end

  describe "get_dataset_maps" do
    let(:connection) { BlueStateDigital::Connection.new({}) }
    let(:dataset_map1) do
      {
          map_id:1,
          type:"state"
      }
    end
    let(:dataset_map2) do
      {
          map_id:2,
          type:"downballot"
      }
    end
    let(:response) do
      {
        data:[
          dataset_map1,
          dataset_map2
        ]
      }.to_json
    end
    before :each do
      connection
        .should_receive(:perform_request)
        .with('/cons/list_dataset_maps', {api_ver: 2}, 'GET')
        .and_return(response)
    end
    it "should fetch datasets" do
      dataset_maps = connection.dataset_maps.get_dataset_maps
      dataset_maps.length.should == 2
      dataset_maps[0].to_json.should == dataset_map1.to_json
      dataset_maps[1].to_json.should == dataset_map2.to_json
    end
    context "failure" do
      let(:response) { "Something bad happened" }
      it "should raise exception if fetch fails" do
        expect { connection.dataset_maps.get_dataset_maps }.to raise_error(BlueStateDigital::CollectionResource::FetchFailureException)
      end
    end
  end
end