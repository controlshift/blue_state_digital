require 'spec_helper'

describe BlueStateDigital::Dataset do

  let(:connection) { double }
  let(:slug) { "my_dataset" }
  let(:map_type) { "state" }
  let(:dataset_attributes) do
    {
      "dataset_id"  =>  42,
      "slug"        =>  slug,
      "rows"        =>  100,
      "map_type"    =>  map_type
    }
  end
  subject { BlueStateDigital::Dataset.new(dataset_attributes.merge({connection: connection}))}

  describe "new" do
    it "should accept dataset params" do
      dataset = BlueStateDigital::Dataset.new(dataset_attributes)
      dataset_attributes.each do |k,v|
        dataset.send(k).should == v
      end
    end
  end

  describe "save" do
    context "validations" do
      it "should error if required params are not provided" do
        [:slug,:map_type].each do |field|
          val = subject.send(field)
          subject.send("#{field}=",nil)
          subject.should_not be_valid
          subject.errors.full_messages.should == ["#{field} can't be blank"]
          subject.send("#{field}=",val)
        end
      end
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
          .with('/cons/upload_dataset', {slug: slug,map_type: map_type,:content_type=>"text/csv"}, 'POST',csv)
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
        subject.dataset_id = nil
        subject.delete.should be false
        subject.errors.full_messages.should == ["dataset_id is missing"]
      end
    end
    context "service" do
      let(:dataset_id) { 1 }
      let(:delete_payload){ {dataset_id: dataset_id} }
      before :each do
        connection
          .should_receive(:perform_request_raw)
          .with('/cons/delete_dataset', {}, 'POST',delete_payload.to_json)
          .and_return(response)
      end
      context "failure" do
        let(:response) { Hashie::Mash.new(status: 404,body: "Something bad happened") }
        it "should return false if delete fails" do
          subject.dataset_id = dataset_id
          subject.delete.should be_false
          subject.errors.full_messages.should == ["web_service Something bad happened"]
        end
      end
      context "success" do
        let(:response) { Hashie::Mash.new(status: 200,body: "") }
        it "should return true" do
          subject.dataset_id = dataset_id
          subject.delete.should be_true
          subject.errors.full_messages.should == []
        end
      end
    end
  end

  describe "get_datasets" do
    let(:connection) { BlueStateDigital::Connection.new({}) }
    let(:dataset1) do
      {
          dataset_id:42,
          map_type:"state",
          slug:"my_dataset",
          rows:100,
      }
    end
    let(:dataset2) do
      {
          dataset_id:43,
          map_type:"downballot",
          slug:"downballot_dataset",
          rows:50,
      }
    end
    let(:response) do
      {
      data:[
        dataset1,
        dataset2
      ]
    }
    end
    before :each do
      connection
        .should_receive(:perform_request)
        .with('/cons/list_datasets', { api_ver: 2 }, 'GET')
        .and_return(response)
    end
    it "should fetch datasets" do
      datasets = connection.datasets.get_datasets
      datasets.length.should == 2
      datasets[0].to_json.should == dataset1.to_json
      datasets[1].to_json.should == dataset2.to_json
    end
    context "failure" do
      let(:response) { "Something bad happened" }
      it "should raise exception if fetch fails" do
        expect { connection.datasets.get_datasets }.to raise_error(BlueStateDigital::CollectionResource::FetchFailureException, "Something bad happened")
      end
    end
  end
end