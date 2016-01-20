module BlueStateDigital
  class SignupForm < ApiDataModel
    FIELDS = [:id, :clone_from_id, :signup_form_name, :signup_form_slug, :form_public_title, :create_dt]
    attr_accessor *FIELDS

    def save
      params = {signup_form_id: clone_from_id, title: form_public_title,
                signup_form_name: signup_form_name, slug: signup_form_slug}
      xml_response = connection.perform_request '/signup/clone_form', params, 'POST', nil
      doc = Nokogiri::XML(xml_response)
      record = doc.xpath('//signup_form').first
      if record
        self.id = record.xpath('id').text.to_i
      else
        raise "Set constituent data failed with message: #{xml_response}"
      end
      self
    end
  end
end
