module BlueStateDigital
  class ConstituentGroup < ApiDataModel
    FIELDS = [:id, :name, :slug, :description, :group_type, :create_dt]
    attr_accessor *FIELDS

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
  end

  class ConstituentGroups < CollectionResource
    def add_cons_ids_to_group(cons_group_id, cons_ids)
      cons_ids = cons_ids.is_a?(Array) ? cons_ids : [cons_ids]
      cons_ids.in_groups_of(100) do
        cons_ids_concat = cons_ids.join(',')
        post_params = { cons_group_id: cons_group_id, cons_ids: cons_ids_concat }
        deferred_id = connection.perform_request '/cons_group/add_cons_ids_to_group', post_params, "POST"

        result = nil
        while result.nil?
          result = connection.get_deferred_results(deferred_id)
        end
      end
    end

    def create(attrs = {})
      cons_group = ConstituentGroup.new(attrs)

      xml = connection.perform_request '/cons_group/add_constituent_groups', {}, "POST", cons_group.to_xml
      doc = Nokogiri::XML(xml)
      group = doc.xpath('//cons_group')

      cons_group.id = group.first[:id]
      cons_group
    end

    def find_or_create(attr = {})
      group = get_constituent_group_by_slug(attr[:slug])
      if group
        return group
      else
        return create(attr)
      end
    end

    def list_constituent_groups
      from_response(connection.perform_request '/cons_group/list_constituent_groups', {}, "GET")
    end

    def get_constituent_group(id)
      from_response(connection.perform_request '/cons_group/get_constituent_group', {cons_group_id: id}, "GET")
    end

    def find_by_id(id)
      get_constituent_group(id)
    end

    def delete_constituent_groups(group_ids)
      group_ids_concat = group_ids.is_a?(Array) ? group_ids.join(',') : group_ids.to_s
      deferred_id = connection.perform_request '/cons_group/delete_constituent_groups', {cons_group_ids: group_ids_concat}, "POST"
      result = nil
      while result.nil?
        result = connection.get_deferred_results(deferred_id)
      end
      result
    end

    def get_constituent_group_by_name( name )
      name = name.slice(0..254)
      from_response( connection.perform_request '/cons_group/get_constituent_group_by_name', {name: name}, "GET" )
    end

    def get_constituent_group_by_slug( slug )
      slug = slug.slice(0..31)
      from_response( connection.perform_request '/cons_group/get_constituent_group_by_slug', {slug: slug}, "GET" )
    end

    # Warning: this is an expensive, potentially dangerous operation!
    def replace_constituent_group!(old_group_id, new_group_attrs)
      # first, check to see if this group exists.
      group = get_constituent_group(old_group_id)
      raise "Group being renamed does not exist!" if group.nil?

      cons_ids  = get_cons_ids_for_group(old_group_id)
      delete_constituent_groups(old_group_id)

      new_group = find_or_create(new_group_attrs)
      add_cons_ids_to_group(new_group.id, cons_ids)

      new_group
    end

    def get_cons_ids_for_group(cons_group_id)
      deferred_id = connection.perform_request '/cons_group/get_cons_ids_for_group', {cons_group_id: cons_group_id}, "GET"

      result = nil
      while result.nil?
        result = connection.get_deferred_results(deferred_id)
      end
      result
    end


    private

    def from_response(string)
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

    def from_hash(hash)
      attrs  = {}
      ConstituentGroup::FIELDS.each do | field |
        attrs[field] = hash[field.to_s] if hash[field.to_s].present?
      end
      ConstituentGroup.new(attrs)
    end
  end
end