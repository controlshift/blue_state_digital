module BlueStateDigital
  class ConstituentDataBuilder
    def self.from_hash(data)
      xml_data = %q{<?xml version="1.0" encoding="utf-8"?>}
      xml_data << "<api>"
      xml_data << cons(data)
      xml_data << "</api>"
      xml_data
    end
    
    def self.cons(data)
      id_attr = data[:id].nil? ? '' : " id=\"#{data[:id]}\""
      ext_id_attr = data[:ext_id].nil? ? '' : " ext_id=\"#{data[:ext_id]}\""
      ext_type_attr = data[:ext_type].nil? ? '' : " ext_type=\"#{data[:ext_type]}\""
      cons_data = "<cons#{id_attr}#{ext_id_attr}#{ext_type_attr}>"
      cons_data << "<firstname>#{value_or_default(data[:first_name], '')}</firstname>"
      cons_data << "<lastname>#{value_or_default(data[:last_name], '')}</lastname>"
      cons_data << "<is_banned>#{value_or_default(data[:is_banned], '0')}</is_banned>"
      cons_data << "<create_dt>#{value_or_default(data[:created_at], '')}</create_dt>"
      emails = data[:emails]
      unless emails.nil?
        emails.each do |email|
          cons_data << cons_email(email)
        end
      end
      cons_data << "</cons>"
      cons_data
    end
    
    def self.cons_email(data)
      cons_email = '<cons_email>'
      cons_email << "<email>#{value_or_default(data[:email], '')}</email>"
      cons_email << "<email_type>#{value_or_default(data[:email_type], 'personal')}</email_type>"
      cons_email << "<is_subscribed>#{value_or_default(data[:is_subscribed], '0')}</is_subscribed>"
      cons_email << "<is_primary>#{value_or_default(data[:is_primary], '0')}</is_primary>"
      cons_email << '</cons_email>'
      cons_email
    end
    
    def self.value_or_default(value, default_value)
      if value.is_a?(TrueClass) || value.is_a?(FalseClass)
        value ? '1' : '0'
      elsif value.is_a?(String)
        value.nil? || value.empty? ? default_value : value
      elsif value.is_a?(Time)
        value.nil? ? default_value : value.utc.to_i
      else
        value.nil? ? default_value : value
      end
    end
  end
end