# <addr1>123 Fake St.</addr1>
# <addr2></addr2>
# <city>Anytown</city>
# <state_cd>CA</state_cd>
# <zip>92345</zip>
# <zip_4>8311</zip_4>
# <country>US</country>
# <is_primary>1</is_primary>
# <latitude>42.000</latitude>
# <longitude>71.000</longitude>

module BlueStateDigital
  class Address < ApiDataModel
    FIELDS = [:addr1, :addr2, :city, :state_cd, :zip, :zip_4, :country, :is_primary, :latitude, :longitude]
    attr_accessor *FIELDS

    def to_xml(builder = Builder::XmlMarkup.new)
      builder.addr do | addr |
        FIELDS.each do | field |
          addr.__send__(field, self.send(field)) if self.send(field)
        end
      end
      builder
    end

  end
end
