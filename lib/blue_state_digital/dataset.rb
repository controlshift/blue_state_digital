module BlueStateDigital
  class Dataset < ApiDataModel

    extend ActiveModel::Naming
    include ActiveModel::Validations

    UPLOAD_ENDPOINT = '/cons/upload_dataset'
    FETCH_ENDPOINT = '/cons/list_datasets'

    FIELDS = [
      :dataset_id,
      :map_type,
      :slug,
      :rows
    ]
    attr_accessor *FIELDS
    attr_reader   :data,:data_header,:errors

    validates_presence_of :map_type, :slug
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
            {slug: slug, map_type: map_type}, 
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
    def find_all
      if connection
          response = connection.perform_request FETCH_ENDPOINT, {}, "GET"
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
end