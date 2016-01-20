module BlueStateDigital
  class SignupForm < ApiDataModel
    FIELDS = [:id, :name, :slug, :public_title, :create_dt]
    attr_accessor *FIELDS

    def self.clone(options)
      clone_from_id = options[:clone_from_id]
      slug = options[:slug]
      name = options[:name]
      public_title = options[:public_title]
      connection = options[:connection]

      params = {signup_form_id: clone_from_id, title: public_title, signup_form_name: name, slug: slug}
      xml_response = connection.perform_request '/signup/clone_form', params, 'POST', nil

      doc = Nokogiri::XML(xml_response)
      record = doc.xpath('//signup_form').first
      if record
        id = record.xpath('id').text.to_i
        SignupForm.new(id: id, name: name, slug: slug, public_title: public_title, connection: connection)
      else
        raise "Set constituent data failed with message: #{xml_response}"
      end
    end
  end
end
