module BlueStateDigital
  class Contribution < ApiDataModel
  	#TODO are we sure we want to raise an exception on save?
  	class ContributionExternalIdMissingException < StandardError
  		def initialize
  			super("Missing GUID for ID")
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
    	:id,
	  	:prefix,:firstname,:middlename,:lastname,:suffix,
	  	:transaction_dt,:transaction_amt,:cc_type_cd,:gateway_transaction_id,
	  	:contribution_page_id,:stg_contribution_recurring_id,:contribution_page_slug,
	  	:outreach_page_id,:source,:opt_compliance,
	  	:addr1,:addr2,:city,:state_cd,:zip,:country,
	  	:phone,:email,
	  	:employer,:occupation,
	  	:customFields
  	]
    attr_accessor *FIELDS

    def save
    	begin
	    	if connection
	    		response = JSON.parse(connection.perform_request( 
	    			'/contribution/add_external_contribution',
	    			{accept: 'application/json'},
	    			'POST',
	    			self.to_json
	    		))
	    		if(response['summary']['missing_ids']>0)
	    			raise ContributionExternalIdMissingException.new
	    		elsif(response['summary']['failures']>0)
	    			raise ContributionSaveValidationException.new(response['errors'])
	    		end	
	    	else
	    		raise NoConnectionException.new
	    	end
	    	self
    	rescue => e
    		raise e
    	end
    end
  end

end
