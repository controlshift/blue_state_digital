require 'builder'

module BlueStateDigital::Models
  class ConstituentGroup
    attr_accessor :name, :slug, :description, :group_type, :created_at
    
    def initialize(attrs = {})
      attrs.each do |key, value|
        if self.respond_to?("#{key}=")
          self.send("#{key}=", value)
        end
      end
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
          cons_group.create_dt(@created_at.utc.to_i) unless @created_at.nil?
        end
      end
    end
    
    def to_s
      to_xml
    end
  end
end