require 'spec_helper'

describe BlueStateDigital::Dataset do
	describe "new" do
		let(:dataset_attributes) do
			{
	            "dataset_id"	=>	42,
	            "slug"			=>	"my_dataset",
	            "rows"			=>	100,
	            "map_type"		=>	"state"
        	} 
        end
		it "should accept dataset params" do
			dataset = BlueStateDigital::Dataset.new(dataset_attributes)
			dataset_attributes.each do |k,v|
				dataset.send(k).should == v
			end	
		end
	end
end