 module BlueStateDigital
 	class ListDatasets < CollectionResource
 		def fetch
 			if connection
 				response = connection.perform_request '/cons/list_datasets', {}, "GET"
 				if(response.is_a?Hash)
	 				data=response[:data]
	 				if(data)
	 					data.map do |dataset|
	 						Dataset.new(dataset)
	 					end
	 				else
	 					nil
	 				end
	 			else
	 				raise FetchFailureException.new("#{response}")
	 			end
 			else
 				raise NoConnectionException.new
 			end
 		end
 	end
end