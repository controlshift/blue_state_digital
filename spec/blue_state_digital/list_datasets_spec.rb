require 'spec_helper'

describe BlueStateDigital::ListDatasets do
  let(:connection) { double }
  subject { BlueStateDigital::ListDatasets.new(connection) }
  let(:dataset1) do
    {
        dataset_id:42,
        slug:"my_dataset",
        rows:100,
        map_type:"state"
    }
  end
  let(:dataset2) do
    {
        dataset_id:43,
        slug:"downballot_dataset",
        rows:50,
        map_type:"downballot"
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
      .with('/cons/list_datasets', {}, 'GET')
      .and_return(response)
  end
  it "should fetch datasets" do
    datasets = subject.fetch
    datasets.length.should == 2
    datasets[0].to_json.should == dataset1.to_json
    datasets[1].to_json.should == dataset2.to_json
  end
  context "failure" do
    let(:response) { "Something bad happened" }
    it "should raise exception" do
      expect { subject.fetch }.to raise_error(BlueStateDigital::CollectionResource::FetchFailureException, "Something bad happened")
    end
  end
end