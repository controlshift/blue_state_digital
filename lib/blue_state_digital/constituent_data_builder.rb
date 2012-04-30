require 'builder'

module BlueStateDigital
  class ConstituentDataBuilder

    def self.from_hash(data)
      buffer = ""
      xml = Builder::XmlMarkup.new(:target => buffer)
      
      xml.instruct! :xml, :version => "1.0", :encoding => "utf-8"
      xml.api do | xml |
        xml = build_constituent(data, xml)
      end
      
      buffer
    end
    
    def self.build_constituent(data, xml)

      xml.cons( {:id => data[:id], :ext_id => data[:ext_id], :ext_type => data[:ext_type]}.reject{|k,v| v.nil?} ) do | cons |
        cons.firstname( value_or_default(data[:first_name], ''))
        cons.lastname( value_or_default(data[:last_name], ''))
        cons.is_banned( value_or_default(data[:is_banned], '0'))
        cons.create_dt( value_or_default(data[:created_at], ''))
        emails = data[:emails]
        unless emails.nil?
          emails.each do |email|
            email = build_constituent_email(email, cons)
          end
        end
      end
    end
    
    def self.build_constituent_email(data, cons)
      cons.cons_email do | cons_email |
        cons_email.email(value_or_default(data[:email], ''))
        cons_email.email_type(value_or_default(data[:email_type], 'personal'))
        cons_email.is_subscribed( value_or_default(data[:is_subscribed], '0'))
        cons_email.is_primary(value_or_default(data[:is_primary], '0'))
      end
      cons
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