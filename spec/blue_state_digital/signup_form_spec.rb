require 'spec_helper'

describe BlueStateDigital::SignupForm do
  let(:connection) { BlueStateDigital::Connection.new({}) }

  describe '.clone' do
    it 'should create a new SignupForm' do
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

      form = BlueStateDigital::SignupForm.clone(clone_from_id: 1, slug: 'foo', name: 'Signup Form Foo',
                                                public_title: 'Sign Up Here', connection: connection)
      expect(form.id).to eq(3)
      expect(form.name).to eq('Signup Form Foo')
      expect(form.slug).to eq('foo')
      expect(form.public_title).to eq('Sign Up Here')
    end
  end
end
