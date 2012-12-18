# <phone>0408573670</phone>
# <phone_type>unknown</phone_type>
# <is_subscribed>1</is_subscribed>
# <is_primary>1</is_primary>
module BlueStateDigital
  class Phone < ApiDataModel
    FIELDS = [:phone, :phone_type, :is_primary, :is_subscribed]
    attr_accessor *FIELDS

    def to_xml(builder = Builder::XmlMarkup.new)
      builder.phone do | phone |
        FIELDS.each do | field |
          phone.__send__(field, self.send(field)) if self.send(field)
        end
      end
      builder
    end

  end
end
