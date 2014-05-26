module BlueStateDigital
  class DatasetMap < ApiDataModel

    extend ActiveModel::Naming
    include ActiveModel::Validations

    UPLOAD_ENDPOINT = '/cons/upload_dataset_map'
    DELETE_ENDPOINT = '/cons/delete_dataset_map'

    FIELDS = [
      :map_id,
      :type
    ]
    attr_accessor *FIELDS
    attr_reader   :data,:data_header,:errors

    validate :data_must_have_header

    def initialize(args={})
      super
      @data = []
      @data_header = nil
      @errors = ActiveModel::Errors.new(self)
    end

    def data
      @data
    end

    def add_data_row(row)
      @data.push row
    end

    def add_data_header(header_row)
      @data_header = header_row
    end

    def save
      #errors.add(:data, "cannot be blank") if @data.blank?
      if valid?
        if connection
          response = connection.perform_request_raw(
            UPLOAD_ENDPOINT,
            { api_ver: 2, content_type: "text/csv" },
            "POST",
            csv_payload
          )
          if(response.status==200)
            true
          else
            errors.add(:web_service,"#{response.body}")
            false
          end
        else
          errors.add(:connection,"is missing")
          false
        end
      else
        false
      end
    end

    def delete
    	if map_id.nil?
    		errors.add(:map_id,"is missing")
    		return false
    	end
    	if connection
          response = connection.perform_request_raw(
            DELETE_ENDPOINT,
            { api_ver: 2 },
            "POST",
            {map_id: map_id}.to_json
          )
          if(response.status==200)
            true
          else
            errors.add(:web_service,"#{response.body}")
            false
          end
        else
          errors.add(:connection,"is missing")
          false
        end
    end

    def read_attribute_for_validation(attr)
      send(attr)
    end
    def self.human_attribute_name(attr, options = {})
      attr
    end
    def self.lookup_ancestors
      [self]
    end

    private

    def csv_payload
      csv_string = CSV.generate do |csv|
        csv << (@data_header||[])
        @data.each do |row|
          csv << row
        end
      end
    end

    def data_must_have_header
      errors.add(:data_header, "is missing") if !@data.blank? && @data_header.nil?
    end
  end

  class DatasetMaps < CollectionResource
    FETCH_ENDPOINT = '/cons/list_dataset_maps'
    def get_dataset_maps
      if connection
        response = connection.perform_request FETCH_ENDPOINT, { api_ver: 2 }, "GET"
        # TODO: Should check response's status code
        begin
          parsed_response = JSON.parse(response)

          data = parsed_response['data']
          if(data)
            data.map do |dataset|
              DatasetMap.new(dataset)
            end
          else
            nil
          end
        rescue Exception => e
          raise FetchFailureException.new("#{e}")
        end
      else
        raise NoConnectionException.new
      end
    end
  end
end