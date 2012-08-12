require 'builder'
require 'nokogiri'
require 'active_support/core_ext'

require_relative 'api_data_model'

module BlueStateDigital
  class ConstituentGroup < ApiDataModel
    FIELDS = [:id, :name, :slug, :description, :group_type, :create_dt]
    attr_accessor FIELDS
    
    def self.add_cons_ids_to_group(cons_group_id, cons_ids)
      cons_ids_concat = cons_ids.is_a?(Array) ? cons_ids.join(',') : cons_ids
      post_params = { cons_group_id: cons_group_id, cons_ids: cons_ids_concat }
      BlueStateDigital::Connection.perform_request '/cons_group/add_cons_ids_to_group', post_params, "POST"
    end
    
    def self.create(attrs = {})
      cons_group = ConstituentGroup.new(attrs)

      xml = BlueStateDigital::Connection.perform_request '/cons_group/add_constituent_groups', {}, "POST", cons_group.to_xml
      doc = Nokogiri::XML(xml)
      group = doc.xpath('//cons_group')

      cons_group.id = group.first[:id]
      cons_group
    end

    def self.find_or_create(attr = {})
      group = get_constituent_group_by_name(attr[:name])
      if group
        return group
      else
        return create(attr)
      end
    end

    def self.get_constituent_group_by_name( name )
      from_response( BlueStateDigital::Connection.perform_request '/cons_group/get_constituent_group_by_name', {name: name}, "GET" )
    end
    
    def to_xml
      builder = Builder::XmlMarkup.new
      builder.instruct! :xml, version: '1.0', encoding: 'utf-8'
      builder.api do |api|
        api.cons_group do |cons_group|
          cons_group.name(@name) unless @name.nil?
          cons_group.slug(@slug) unless @slug.nil?
          cons_group.description(@description) unless @description.nil?
          cons_group.group_type(@group_type) unless @group_type.nil?
          cons_group.create_dt(@create_dt) unless @create_dt.nil?
        end
      end
    end

    private

    def self.from_response(string)
      result = Crack::XML.parse(string)
      if result["api"].present?
        from_hash(result["api"])
      else
        nil
      end
    end

    def self.from_hash(hash)
      group_hash = hash["cons_group"]
      attrs  = {}
      FIELDS.each do | field |
        attrs[field] = group_hash[field.to_s] if group_hash[field.to_s].present?
      end
      ConstituentGroup.new(attrs)
    end
  end
end