require 'spec_helper'

describe BlueStateDigital::Contribution do
  let(:attributes) { 
    {
      external_id:      'GUID_1234',
      firstname:        'carlos',
      lastname:         'the jackal',
      transaction_amt:  1.0,
      transaction_dt:   '2012-12-31 23:59:59',
      cc_type_cd:       'vs'
    } 
  }

  it { should have_fields(
    :external_id,
    :prefix,:firstname,:middlename,:lastname,:suffix,
    :transaction_dt,:transaction_amt,:cc_type_cd,:gateway_transaction_id,
    :contribution_page_id,:stg_contribution_recurring_id,:contribution_page_slug,
    :outreach_page_id,:source,:opt_compliance,
    :addr1,:addr2,:city,:state_cd,:zip,:country,
    :phone,:email,
    :employer,:occupation,
    :custom_fields
    ) }

  describe 'save' do
    let(:connection) { double }
    let(:contribution) { BlueStateDigital::Contribution.new(attributes.merge({ connection: connection })) }

    before :each do
      connection
        .should_receive(:perform_request)
        .with(
          '/contribution/add_external_contribution', 
          {accept: 'application/json'}, 
          'POST',
          [contribution].to_json
        )
        .and_return(response)
    end

    context 'successful' do
      let(:response) {
        { 
          'summary'=> { 
            'sucesses'=>   1, 
            'failures'=>     0, 
            'missing_ids'=>  0 
          }, 
          'errors'=> {
          } 
        }.to_json
      }

      it "should perform API request" do
        saved_contribution = contribution.save
        saved_contribution.should_not be_nil
      end
    end

    context 'failure' do
      context 'bad request' do
        let(:response) { 'Method add_external_contribution expects a JSON array.' }
        it "should raise error" do
          expect { contribution.save }.to raise_error(
            BlueStateDigital::Contribution::ContributionSaveFailureException,
            /Method add_external_contribution expects a JSON array/m
          )
        end
      end   
      context 'missing ID' do
        let(:response) {
          { 
            'summary'=> { 
              'sucesses'=>  0, 
              'failures'=>    0, 
              'missing_ids'=>  1
            }, 
            'errors'=>{
            } 
          }.to_json
        }
        it "should raise error" do
          expect { contribution.save }.to raise_error(
            BlueStateDigital::Contribution::ContributionExternalIdMissingException
          )
        end
      end
      context 'validation errors' do
        let(:response) {
          { 
            'summary'=> { 
              'sucesses'=>  0, 
              'failures'=>    1, 
              'missing_ids'=> 0
            }, 
            'errors'=>{ 
              'UNIQUE_ID_1234567890'=>
                [
                  'Parameter source is expected to be a list of strings', 
                  'Parameter email does not appear to be a valid email address.'
                ] 
              }
          }.to_json
        }
        it "should raise error" do
          expect { contribution.save }.to raise_error(
            BlueStateDigital::Contribution::ContributionSaveValidationException,
            /Error for Contribution.ID. UNIQUE_ID_1234567890.. Parameter source is expected to be a list of strings, Parameter email does not appear to be a valid email address/m
            )
        end
      end
    end
  end

  describe 'get_contributions' do
    let(:connection) { BlueStateDigital::Connection.new({}) }
    let(:response) do
          [ 
            { 
              "stg_contribution_id"=> 1, 
              "cons_id"=> 1, 
              "date"=> "2012-07-19 00:05:55", 
              "contribution_key"=> "GdAzDC9hHwYaQlszcY", 
              "ip_address"=> "127.0.0.1", 
              "prefix"=> nil, 
              "first_name"=> "John", 
              "middle_name"=> nil, 
              "last_name"=> "Doe", 
              "suffix"=> nil, 
              "email"=> "john@doe.com", 
              "amount"=> "25.00", 
              "tickets"=> nil, 
              "occupation"=> nil, 
              "employer"=> nil, 
              "phone"=> 1238675309, 
              "addr1"=> "123 First Ave", 
              "addr2"=> nil, 
              "city"=> "landville", 
              "state_cd"=> "AA", 
              "postal_code"=> "00000", 
              "country"=> "AA", 
              "card_type"=> "vs", 
              "card_last_4"=> "0000", 
              "custom1"=> nil, 
              "custom2"=> nil, 
              "custom3"=> nil, 
              "source"=> ["somepage"], 
              "custom_country_field1"=> nil, 
              "custom_country_field2"=> nil, 
              "bill_ref_num"=> "74B49741TE455931Y", 
              "page_name"=> "General donation page", 
              "note"=> nil, 
              "outreach"=> nil, 
              "ext_id"=> nil, 
              "facebook"=> nil 
            } 
          ].to_json 
    end
    let(:filters) do
      {
        :date               => "custom",
        :start              => "2012-07-19 00:05:55",
        :type               => "all",
        :source             => ["apple","banana"],
        :contribution_pages =>  [1,2,3]
      }  
    end
    context 'successful' do
      it 'should fetch' do
        connection.should_receive(:perform_request).with('/contribution/get_contributions', {:filter=>{}}, "GET").and_return("deferred_id")
        connection.should_receive(:perform_request).with('/get_deferred_results', {deferred_id: "deferred_id"}, "GET").and_return(response)
        contributions = connection.contributions.get_contributions
        contributions.should_not be_nil
        contributions.length.should == 1
        contributions.to_json.should == response
      end
      it 'should support filters' do
        connection.should_receive(:perform_request).with(
          '/contribution/get_contributions', 
          {:filter=>filters}, 
          "GET"
        ).and_return("deferred_id")
        connection.should_receive(:perform_request).with('/get_deferred_results', {deferred_id: "deferred_id"}, "GET").and_return(response)
        contributions = connection.contributions.get_contributions(filters)  
      end
    end
  end
end