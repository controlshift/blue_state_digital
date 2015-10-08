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
        expect(dataset.send(k)).to eq(v)
      end
    end
  end

  describe "save" do
    context "validations" do
      it "should error if required params are not provided" do
        [:slug,:map_type].each do |field|
          val = subject.send(field)
          subject.send("#{field}=",nil)
          expect(subject).not_to be_valid
          expect(subject.errors.full_messages).to eq(["#{field} can't be blank"])
          subject.send("#{field}=",val)
        end
      end

      it "should not error if there is no data" do
        expect(subject.data).to be_blank
        expect(subject).to be_valid
      end

      it "should error if there is data but no data header" do
        subject.add_data_row([1])
        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to eq(["data_header is missing"])
      end
    end

    context "csv upload" do
      let(:header) { ['a','b','c','d'] }
      let(:row1) { ['1','2','3','4'] }
      let(:csv) { "#{header.join(',')}\n#{row1.join(',')}\n"}
      let(:response) { Hashie::Mash.new(status: 202, body: "accepted") }

      before(:each) do
        expect(connection)
          .to receive(:perform_request_raw)
          .with('/cons/upload_dataset', { api_ver: 2, slug: slug,map_type: map_type, content_type: "text/csv", accept: "application/json" }, 'PUT',csv)
          .and_return(response)
      end


      it "should convert data into csv and dispatch" do
        subject.add_data_header(header)
        subject.add_data_row(row1)
        expect(subject.save).to be_truthy
      end

      context "failure" do
        let(:response) { Hashie::Mash.new(status: 404,body: "Something bad happened") }

        it "should return false if save fails" do
          subject.add_data_header(header)
          subject.add_data_row(row1)
          expect(subject.save).to be_falsey
        end
      end
    end
  end

  describe "delete" do
    context "validations" do
      it "should complaing if map_id is not provided" do
        subject.dataset_id = nil
        expect(subject.delete).to be false
        expect(subject.errors.full_messages).to eq(["dataset_id is missing"])
      end
    end

    context "service" do
      let(:dataset_id) { 1 }
      let(:delete_payload){ {dataset_id: dataset_id} }

      before :each do
        expect(connection)
          .to receive(:perform_request_raw)
          .with('/cons/delete_dataset', {api_ver: 2}, 'POST',delete_payload.to_json)
          .and_return(response)
      end

      context "failure" do
        let(:response) { Hashie::Mash.new(status: 404,body: "Something bad happened") }

        it "should return false if delete fails" do
          subject.dataset_id = dataset_id
          expect(subject.delete).to be_falsey
          expect(subject.errors.full_messages).to eq(["web_service Something bad happened"])
        end
      end

      context "success" do
        let(:response) { Hashie::Mash.new(status: 200,body: "") }

        it "should return true" do
          subject.dataset_id = dataset_id
          expect(subject.delete).to be_truthy
          expect(subject.errors.full_messages).to eq([])
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
      }.to_json
    end

    before :each do
      expect(connection)
        .to receive(:perform_request)
        .with('/cons/list_datasets', { api_ver: 2 }, 'GET')
        .and_return(response)
    end

    it "should fetch datasets" do
      datasets = connection.datasets.get_datasets
      expect(datasets.length).to eq(2)
      expect(datasets[0].to_json).to eq(dataset1.to_json)
      expect(datasets[1].to_json).to eq(dataset2.to_json)
    end

    context "failure" do
      let(:response) { "Something bad happened" }

      it "should raise exception if fetch fails" do
        expect { connection.datasets.get_datasets }.to raise_error(BlueStateDigital::CollectionResource::FetchFailureException)
      end
    end
  end
end