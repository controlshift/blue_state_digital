require 'builder'
require 'nokogiri'
require 'active_support/core_ext'
require 'crack/xml'

require_relative 'api_data_model'

module BlueStateDigital
  class ConstituentGroup < ApiDataModel
    FIELDS = [:id, :name, :slug, :description, :group_type, :create_dt]
    attr_accessor *FIELDS
    
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
      group = get_constituent_group_by_slug(attr[:slug])
      if group
        return group
      else
        return create(attr)
      end
    end
    
    def self.list_constituent_groups
      from_response(BlueStateDigital::Connection.perform_request '/cons_group/list_constituent_groups', {}, "GET")
    end

    def self.find_by_id(id)
      list_constituent_groups.select{| group | group.id.to_s == id.to_s}.first
    end

    def self.delete_constituent_groups(group_ids)
      group_ids_concat = group_ids.is_a?(Array) ? group_ids.join(',') : group_ids.to_s
      BlueStateDigital::Connection.perform_request '/cons_group/delete_constituent_groups', {cons_group_ids: group_ids_concat}, "POST"
    end

    def self.get_constituent_group_by_name( name )
      name = name.slice(0..254)
      from_response( BlueStateDigital::Connection.perform_request '/cons_group/get_constituent_group_by_name', {name: name}, "GET" )
    end

    def self.get_constituent_group_by_slug( slug )
      slug = slug.slice(0..31)
      from_response( BlueStateDigital::Connection.perform_request '/cons_group/get_constituent_group_by_slug', {slug: slug}, "GET" )
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
      parsed_result = Crack::XML.parse(string)
      if parsed_result["api"].present?
        if parsed_result["api"]["cons_group"].is_a?(Array)
          results = []
          parsed_result["api"]["cons_group"].each do |cons_group|
            results << from_hash(cons_group)
          end
          return results
        else
          return from_hash(parsed_result["api"]["cons_group"])
        end
      else
        nil
      end
    end

    def self.from_hash(hash)
      attrs  = {}
      FIELDS.each do | field |
        attrs[field] = hash[field.to_s] if hash[field.to_s].present?
      end
      ConstituentGroup.new(attrs)
    end
  end
end