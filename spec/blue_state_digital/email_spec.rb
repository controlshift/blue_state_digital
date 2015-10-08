require 'spec_helper'

describe BlueStateDigital::Email do
    describe :to_hash do
      it "should return a hash of all fields" do
        attr_hash = {email: '123432', email_type: 'personal', is_primary: '1', is_subscribed: '0'}
        phone = BlueStateDigital::Email.new attr_hash
        expect(phone.to_hash).to eq(attr_hash)
      end
      it "should include nil fields" do
        expected_hash = {email: nil, email_type: nil, is_primary: nil, is_subscribed: nil}
        phone = BlueStateDigital::Email.new {}
        expect(phone.to_hash).to eq(expected_hash)
      end
    end
end