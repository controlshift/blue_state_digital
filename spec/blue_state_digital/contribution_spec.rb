require 'spec_helper'

describe BlueStateDigital::Contribution do
  let(:attributes) { {} }

    it { should have_fields(
      :id,
      :prefix,:firstname,:middlename,:lastname,:suffix,
      :transaction_dt,:transaction_amt,:cc_type_cd,:gateway_transaction_id,
      :contribution_page_id,:stg_contribution_recurring_id,:contribution_page_slug,
      :outreach_page_id,:source,:opt_compliance,
      :addr1,:addr2,:city,:state_cd,:zip,:country,
      :phone,:email,
      :employer,:occupation,
      :customFields
      ) }

  describe 'save' do
    let(:connection) { double }
    let(:contribution) { BlueStateDigital::Contribution.new(attributes.merge({ connection: connection })) }

    before :each do
      connection
        .should_receive(:perform_request)
        .with('/contribution/add_external_contribution', {accept: 'application/json'}, 'POST',contribution.to_json)
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
          expect { contribution.save }.to raise_error(BlueStateDigital::Contribution::ContributionExternalIdMissingException)
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
end