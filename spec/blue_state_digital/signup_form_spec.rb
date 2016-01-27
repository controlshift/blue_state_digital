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
      expect(connection).to receive(:perform_request).with('/signup/clone_form', {}, 'POST',
                                                           {signup_form_id: 1,
                                                            title: 'Sign Up Here',
                                                            signup_form_name: 'Signup Form Foo',
                                                            slug: 'foo'}).and_return(response)

      form = BlueStateDigital::SignupForm.clone(clone_from_id: 1, slug: 'foo', name: 'Signup Form Foo',
                                                public_title: 'Sign Up Here', connection: connection)
      expect(form.id).to eq(3)
      expect(form.name).to eq('Signup Form Foo')
      expect(form.slug).to eq('foo')
      expect(form.public_title).to eq('Sign Up Here')
    end
  end

  describe '#process_signup' do
    let(:signup_form) { BlueStateDigital::SignupForm.new(id: 3, name: 'A Form', slug: 'asdf', public_title: 'The Best Form', connection: connection) }
    let(:list_form_fields_response) { <<-EOF
      <?xml version="1.0" encoding="utf-8"?>
      <api>
        <signup_form_field id="83">
          <format>1</format>
          <label>First Name</label>
          <description>First Name</description>
          <display_order>1</display_order>
          <is_shown>1</is_shown>
          <is_required>0</is_required>
          <break_after>0</break_after>
          <is_custom_field>0</is_custom_field>
          <cons_field_id>0</cons_field_id>
          <create_dt>2010-02-08 18:33:11</create_dt>
          <extra_def></extra_def>
        </signup_form_field>
        <signup_form_field id="84">
          <format>1</format>
          <label>Last Name</label>
          <description>Last Name</description>
          <display_order>2</display_order>
          <is_shown>1</is_shown>
          <is_required>0</is_required>
          <break_after>0</break_after>
          <is_custom_field>0</is_custom_field>
          <cons_field_id>0</cons_field_id>
          <create_dt>2010-02-08 18:33:11</create_dt>
          <extra_def></extra_def>
        </signup_form_field>
      </api>
    EOF
    }

    before :each do
      allow(connection).to receive(:perform_request).with('/signup/list_form_fields',
                                                          {signup_form_id: signup_form.id},
                                                          'GET', nil).and_return(list_form_fields_response)
    end

    it 'should call process_signup' do
      expected_body_readable = <<-EOF
        <?xml version="1.0" encoding="utf-8"?>
        <api>
          <signup_form id="3">
            <signup_form_field id="83">Susan</signup_form_field>
            <signup_form_field id="84">Anthony</signup_form_field>
            <email_opt_in>1</email_opt_in>
            <source>foo</source>
          </signup_form>
        </api>
      EOF
      expected_body = expected_body_readable.squish.gsub('> <', '><')

      expect(connection).to receive(:perform_request_raw).with('/signup/process_signup', {}, 'POST', expected_body).and_return(double(body: '', status: 200))

      signup_data = {'First Name' => 'Susan', 'Middle Initial' => 'B', 'Last Name' => 'Anthony'}
      signup_form.process_signup(field_data: signup_data, email_opt_in: true, source: 'foo')
    end
  end

  describe '#set_cons_group' do
    let(:signup_form) { BlueStateDigital::SignupForm.new(id: 3, name: 'A Form', slug: 'asdf', public_title: 'The Best Form', connection: connection) }
    let(:cons_group_id) { 123 }

    it 'should call set_cons_group' do
      expect(connection).to receive(:perform_request).with('/signup/set_cons_group', {signup_form_id: signup_form.id}, 'POST', {cons_group_id: cons_group_id}).and_return('')

      signup_form.set_cons_group(cons_group_id)
    end
  end
end
