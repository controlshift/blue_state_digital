require 'spec_helper'

describe BlueStateDigital::Email do
    describe :to_hash do
      it "should return a hash of all fields" do
        attr_hash = {email: '123432', email_type: 'personal', is_primary: '1', is_subscribed: '0'}
        phone = BlueStateDigital::Email.new attr_hash
        phone.to_hash.should == attr_hash
      end
      it "should include nil fields" do
        expected_hash = {email: nil, email_type: nil, is_primary: nil, is_subscribed: nil}
        phone = BlueStateDigital::Email.new {}
        phone.to_hash.should == expected_hash
      end
    end
end