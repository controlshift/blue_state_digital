require 'builder'
require 'nokogiri'
require_relative 'api_data_model'

module BlueStateDigital
  class ConstituentData < ApiDataModel
    attr_accessor :id, :firstname, :lastname, :is_banned, :create_dt, :ext_id, 
                  :emails, :adresses, :phones, :groups
    
    def self.set(attrs = {})
      cons_data = ConstituentData.new(attrs)
      xml = BlueStateDigital::Connection.perform_request '/cons/set_constituent_data', {}, "POST", cons_data.to_xml
      doc = Nokogiri::XML(xml)
      cons_data.id = doc.xpath('//cons').first[:id]
      cons_data
    end
    
    def to_xml
      builder = Builder::XmlMarkup.new
      builder.instruct! :xml, version: '1.0', encoding: 'utf-8'
      builder.api do |api|
        cons_attrs = {}
        cons_attrs[:id] = @id unless @id.nil?
        unless @ext_id.nil?
          cons_attrs[:ext_id] = @ext_id.id unless @ext_id.id.nil?
          cons_attrs[:ext_type] = @ext_id.type unless @ext_id.type.nil?
        end
        
        api.cons(cons_attrs) do |cons|
          cons.firstname(@firstname) unless @firstname.nil?
          cons.lastname(@lastname) unless @lastname.nil?
          cons.is_banned(@is_banned) unless @is_banned.nil?
          cons.create_dt(@create_dt) unless @create_dt.nil?
          
          unless @emails.nil?
            @emails.each {|email| build_constituent_email(email, cons) }
          end
          unless @adresses.nil?
            @adresses.each {|adress| build_constituent_address(adress, cons) }
          end
          unless @phones.nil?
            @phones.each {|phone| build_constituent_phone(phone, cons) }
          end
          unless @groups.nil?
            @groups.each {|group| build_constituent_group(group, cons) }
          end
        end
      end
    end
    
    private
    
    def build_constituent_group(group, cons)
      cons.cons_group({ id: group })
    end
    
    def build_constituent_email(email, cons)
      cons.cons_email do |cons_email|
        email.each do |key, value|
          eval("cons_email.#{key}('#{value}')") unless value.nil?
        end
      end
    end
    
    def build_constituent_phone(phone, cons)
      cons.cons_phone do |cons_phone|
        phone.each do |key, value|
          eval("cons_phone.#{attr}('#{value}')") unless value.nil?
        end
      end
    end
    
    def build_constituent_address(address, cons)
      cons.cons_addr do |cons_addr|
        address.each do |key, value|
          eval("cons_addr.#{attr}('#{value}')") unless value.nil?
        end
      end
    end
  end
end