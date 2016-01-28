module BlueStateDigital
  class SignupFormField < ApiDataModel
    FIELDS = [:id, :format, :label, :description, :is_required, :is_custom_field, :cons_field_id, :create_dt]
    attr_accessor *FIELDS

    # Takes a <signup_form_field> block already processed by Nokogiri
    def self.from_xml(xml_record)
      SignupFormField.new(id: xml_record[:id],
                          format: xml_record.xpath('format').text,
                          label: xml_record.xpath('label').text,
                          description: xml_record.xpath('description').text,
                          is_required: xml_record.xpath('is_required').text == '1',
                          is_custom_field: xml_record.xpath('is_custom_field').text == '1',
                          cons_field_id: xml_record.xpath('cons_field_id').text.to_i,
                          create_dt: xml_record.xpath('create_dt').text)
    end
  end

  class SignupForm < ApiDataModel
    FIELDS = [:id, :name, :slug, :public_title, :create_dt]
    attr_accessor *FIELDS

    def self.clone(clone_from_id:, slug:, name:, public_title:, connection:)
      params = {signup_form_id: clone_from_id, title: public_title, signup_form_name: name, slug: slug}
      xml_response = connection.perform_request '/signup/clone_form', {}, 'POST', params

      doc = Nokogiri::XML(xml_response)
      record = doc.xpath('//signup_form').first
      if record
        id = record.xpath('id').text.to_i
        SignupForm.new(id: id, name: name, slug: slug, public_title: public_title, connection: connection)
      else
        raise "Cloning signup form failed with message: #{xml_response}"
      end
    end

    # field_data is a hash mapping field labels to field values, like {'First Name' => 'Alice'}
    def process_signup(field_data:, email_opt_in: false, source: nil, subsource: nil)
      # Construct the XML to send
      builder = Builder::XmlMarkup.new
      builder.instruct! :xml, version: '1.0', encoding: 'utf-8'
      xml_body = builder.api do |api|
        api.signup_form(id: self.id) do |form|
          form_fields.each do |field|
            form.signup_form_field(field_data[field.label], id: field.id)
          end
          form.email_opt_in(email_opt_in ? '1' : '0')
          form.source(source) unless source.nil?
          form.subsource(subsource) unless subsource.nil?
        end
      end

      # Post it to the endpoint
      begin
        response = connection.perform_request_raw '/signup/process_signup', {}, 'POST', xml_body
        if response.status >= 200 && response.status < 300
          return true
        else
          raise "process signup failed with message: #{response.body}"
        end
      rescue BlueStateDigital::XmlErrorResponse => err
        begin
          errors = {}
          error_xmls = Nokogiri::XML(err.message).xpath('//error')
          error_xmls.each do |error_xml|
            field = form_fields.select{|field| field.id.to_s == error_xml.xpath('signup_form_field_id').text}.first
            errors[field.label] = error_xml.xpath('description').text
            raise "process_signup failed with errors: #{errors}"
          end
        end
      end
    end

    def set_cons_group(cons_group_id)
      connection.perform_request('/signup/set_cons_group', {signup_form_id: self.id}, 'POST', {cons_group_id: cons_group_id})
    end

    def form_fields
      if @_form_fields.nil?
        xml_response = connection.perform_request '/signup/list_form_fields', {signup_form_id: id}, 'GET', nil
        doc = Nokogiri::XML(xml_response)

        @_form_fields = []
        doc.xpath('//signup_form_field').each do |form_field_record|
          @_form_fields << SignupFormField.from_xml(form_field_record)
        end
      end
      @_form_fields
    end
  end
end
