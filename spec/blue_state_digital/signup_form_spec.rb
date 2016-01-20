require 'spec_helper'

describe BlueStateDigital::SignupForm do
  let(:connection) { BlueStateDigital::Connection.new({}) }

  describe '#save' do
    it 'should clone a form with the specified attributes' do
      response = <<-EOF
        <?xml version="1.0" encoding="utf-8"?>
        <api>
          <signup_form>
            <id>3</id>
          </signup_form>
        </api>
      EOF

      expect(connection).to receive(:perform_request).with('/signup/clone_form',
                                                           {signup_form_id: 1,
                                                            title: 'Sign Up Here',
                                                            signup_form_name: 'Signup Form Foo',
                                                            slug: 'foo'},
                                                           'POST', nil).and_return(response)

      form = BlueStateDigital::SignupForm.new(clone_from_id: 1, signup_form_name: 'Signup Form Foo',
                                              signup_form_slug: 'foo', form_public_title: 'Sign Up Here',
                                              connection: connection)
      form.save
      expect(form.id).to eq(3)
    end
  end
end
