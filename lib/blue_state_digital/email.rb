#    <email>gil+punky1@thoughtworks.com</email>
#    <email_type>personal</email_type>
#    <is_subscribed>1</is_subscribed>
#    <is_primary>1</is_primary>

module BlueStateDigital
  class Email < ApiDataModel
    FIELDS = [:email, :email_type, :is_subscribed, :is_primary]

    attr_accessor *FIELDS

    def to_xml(builder = Builder::XmlMarkup.new)
      builder.email do | email |
        FIELDS.each do | field |
          email.__send__(field, self.send(field)) if self.send(field)
        end
      end
      builder
    end

  end
end
