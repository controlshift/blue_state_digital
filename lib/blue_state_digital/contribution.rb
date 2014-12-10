module BlueStateDigital
  class Contribution < ApiDataModel
    #TODO are we sure we want to raise an exception on save?
    class ContributionExternalIdMissingException < StandardError
      def initialize
        super("Missing GUID for ID")
      end
    end
    class ContributionSaveFailureException < StandardError
      def initialize(msg)
        super
      end  
    end
    class ContributionSaveValidationException < StandardError
      def initialize(validation_errors)
        error_messages = validation_errors.map do |id,msgs|
          "Error for Contribution(ID: #{id}): #{msgs.join(', ')}. " 
        end
        super(error_messages.join(', '))
      end
    end

    FIELDS = [
      :external_id,
      :prefix,:firstname,:middlename,:lastname,:suffix,
      :transaction_dt,:transaction_amt,:cc_type_cd,:gateway_transaction_id,
      :contribution_page_id,:stg_contribution_recurring_id,:contribution_page_slug,
      :outreach_page_id,:source,:opt_compliance,
      :addr1,:addr2,:city,:state_cd,:zip,:country,
      :phone,:email,
      :employer,:occupation,
      :custom_fields
    ]
    attr_accessor *FIELDS

    def as_json(options={})
      fields_to_exclude = []
      fields_to_exclude << :contribution_page_id if contribution_page_id.nil?
      fields_to_exclude << :contribution_page_slug if contribution_page_slug.nil?
      super(options.merge({except: fields_to_exclude}))
    end

    def save
      begin
        if connection
          response = connection.perform_request( 
            '/contribution/add_external_contribution',
            {accept: 'application/json'},
            'POST',
            [self].to_json
          )
          begin
            response = JSON.parse(response)  
          rescue
            raise ContributionSaveFailureException.new(response)
          end
          if(response['summary']['missing_ids']>0)
            raise ContributionExternalIdMissingException.new
          elsif(response['summary']['failures']>0)
            raise ContributionSaveValidationException.new(response['errors'])
          end 
        else
          raise NoConnectionException.new
        end
        #TODO shouldn't we be returning true or false and set the errors as in ActiveModel?
        true
      rescue => e
        raise e
      end
    end
  end

end
