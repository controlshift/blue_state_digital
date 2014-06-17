module BlueStateDigital
  class Constituent < ApiDataModel
    FIELDS = [:id, :firstname, :lastname, :is_banned, :create_dt, :ext_id, :birth_dt, :gender,
                  :emails, :addresses, :phones, :groups, :is_new]
    attr_accessor *FIELDS
    attr_accessor :group_ids

    def initialize(attrs = {})
      super(attrs)
      self.group_ids = []
    end

    def save
      xml = connection.perform_request '/cons/set_constituent_data', {}, "POST", self.to_xml
      doc = Nokogiri::XML(xml)
      record =  doc.xpath('//cons').first
      if record
        self.id = record[:id]
        self.is_new = record[:is_new]
      else
        raise "Set constituent data failed with message: #{xml}"
      end
      self
    end

    def is_new?
      is_new == "1"
    end

    def to_xml
      builder = Builder::XmlMarkup.new
      builder.instruct! :xml, version: '1.0', encoding: 'utf-8'
      builder.api do |api|
        cons_attrs = {}
        cons_attrs[:id] = self.id unless self.id.blank?
        unless self.ext_id.blank?
          cons_attrs[:ext_id] =  self.ext_id.id    unless self.ext_id.id.blank?
          cons_attrs[:ext_type] = self.ext_id.type unless self.ext_id.type.blank?
        end

        api.cons(cons_attrs) do |cons|
          cons.firstname(self.firstname) unless self.firstname.blank?
          cons.lastname(self.lastname)   unless self.lastname.blank?
          cons.is_banned(self.is_banned) unless self.is_banned.blank?
          cons.create_dt(self.create_dt) unless self.create_dt.blank?
          cons.birth_dt(self.birth_dt) unless self.birth_dt.blank?
          cons.gender(self.gender) unless self.gender.blank?

          unless self.emails.blank?
            self.emails.each {|email| build_constituent_email(email, cons) }
          end
          unless self.addresses.blank?
            self.addresses.each {|address| build_constituent_address(address, cons) }
          end
          unless self.phones.blank?
            self.phones.each {|phone| build_constituent_phone(phone, cons) }
          end
          unless self.groups.blank?
            self.groups.each {|group| build_constituent_group(group, cons) }
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
        email.to_hash.each do |key, value|
          eval("cons_email.#{key}('#{value}')") unless value.blank?
        end
      end
    end

    def build_constituent_phone(phone, cons)
      cons.cons_phone do |cons_phone|
        phone.to_hash.each do |key, value|
          eval("cons_phone.#{key}('#{value}')") unless value.blank?
        end
      end
    end

    def build_constituent_address(address, cons)
      cons.cons_addr do |cons_addr|
        address.to_hash.each do |key, value|
          eval("cons_addr.#{key}('#{value}')") unless value.blank?
        end
      end
    end
  end

  class Constituents < CollectionResource
    def get_constituents_by_email email, bundles='cons_group'
      get_constituents "email=#{email}", bundles
    end

    def get_constituents_by_id(cons_ids, bundles = ['cons_group'])
      cons_ids_concat = cons_ids.is_a?(Array) ? cons_ids.join(',') : cons_ids.to_s

      from_response(connection.perform_request('/cons/get_constituents_by_id', {:cons_ids => cons_ids_concat, :bundles=> bundles.join(',')}, "GET"))
    end

    def get_constituents(filter, bundles = 'cons_group')
      result = connection.wait_for_deferred_result( connection.perform_request('/cons/get_constituents', {:filter => filter, :bundles=> bundles.join(',')}, "GET") )

      from_response(result)
    end

    def delete_constituents_by_id(cons_ids)
      cons_ids_concat = cons_ids.is_a?(Array) ? cons_ids.join(',') : cons_ids.to_s
      connection.perform_request('/cons/delete_constituents_by_id', {:cons_ids => cons_ids_concat}, "POST")
    end

    def from_response(string)
      parsed_result = Crack::XML.parse(string)
      if parsed_result["api"].present?
        result = []
        if parsed_result["api"]["cons"].is_a?(Array)
          parsed_result["api"]["cons"].each do |cons_group|
            result << from_hash(cons_group)
          end
        else
          result << from_hash(parsed_result["api"]["cons"])
        end
        return result
      else
        nil
      end
    end

    def from_hash(hash)
      attrs  = {}
      Constituent::FIELDS.each do | field |
        attrs[field] = hash[field.to_s] if hash[field.to_s].present?
      end
      cons = Constituent.new(attrs)
      cons.connection = connection
      if hash['cons_group'].present?
        if hash['cons_group'].is_a?(Array)
          cons.group_ids = hash['cons_group'].collect{|g| g["id"]}
        else
          cons.group_ids << hash['cons_group']["id"]
        end
      end

      if hash['cons_addr'].present?
        if hash['cons_addr'].is_a?(Array)
          cons.addresses = hash['cons_addr'].collect {|addr_hash| BlueStateDigital::Address.new addr_hash}
        else
          cons.addresses = [BlueStateDigital::Address.new(hash['cons_addr'])]
        end
      end

      if hash['cons_email'].present?
        if hash['cons_email'].is_a?(Array)
          cons.emails = hash['cons_email'].collect {|email_hash| BlueStateDigital::Email.new email_hash}
        else
          cons.emails = [BlueStateDigital::Email.new(hash['cons_email'])]
        end
      end

      if hash['cons_phone'].present?
        if hash['cons_phone'].is_a?(Array)
          cons.phones = hash['cons_phone'].collect {|phone_hash| BlueStateDigital::Phone.new phone_hash}
        else
          cons.phones = [BlueStateDigital::Phone.new(hash['cons_phone'])]
        end
      end

      cons
    end
  end
end
