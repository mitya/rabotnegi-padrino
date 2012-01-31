class MongoReflector
  cattr_accessor :collections
  @@collections = {}
  
  def self.metadata_for(key) @@collections[key.to_s] || Collection.new(key.to_s.classify.constantize) end
  def self.define_metadata(&block) Builder.new.instance_eval(&block) end

  class Collection
    attr_accessor :klass, :key
    attr_accessor :list_fields, :list_order, :list_page_size, :list_css_classes
    attr_accessor :view_fields, :view_subcollections, :edit_fields, :actions

    def initialize(klass, key = nil)
      @klass = klass
      @key = key || @klass.model_name.plural

      @view_subcollections = []
      @list_order = [:_id, :desc]
      @list_page_size = 40
      @list_css_classes = ->(m){}
      @actions = {}
    end

    def searchable?
      @klass.respond_to?(:query) 
    end
    
    def plural
      @klass.model_name.plural 
    end
    
    def singular
      @klass.model_name.singular 
    end
    
    def list_fields
      @list_fields || klass_fields 
    end 
      
    def view_fields
      @view_fields || klass_fields 
    end
    
    def stored_fields
      @klass.fields.reject{ |k,f| k.starts_with?('_') }.map{ |k,f| k } 
    end

    private

    def klass_fields
      @klass_fields ||= klass.fields.
        reject { |key, mongo_field| key == '_type' }.
        map { |key, mongo_field| Field.new(key, collection: self) }
    end    
  end
  
  class Field
    attr_accessor :name, :format, :args
    attr_accessor :trim, :css, :link
    attr_accessor :collection

    def initialize(name, options = {})
      @name = name.to_s
      assign_attributes!(options)
    end
    
    def title
      key = @name.gsub('.', '_')
      I18n.t(
        "active_record.attributes.#{collection.singular}.#{key}",
        default: [:"active_record.attributes.common.#{key}", key.humanize]
      )
    end
    
    def custom?
      format.is_a?(Proc)
    end
    
    def css
      Mu.css_classes_for @css, wide: format.in?([:hash, :pre])
    end
    
    def inspect
      Mu.inspection(self, name, format: format)
    end
  end
  
  class Subcollection
    attr_accessor :key, :accessor
    
    def initialize(accessor, key)
      @accessor = accessor
      @key = key
    end
    
    def title
      I18n.t("active_record.attributes.#{collection.singular}.#{accessor}", 
        default: [:"active_record.attributes.common.#{accessor}", accessor.to_s.humanize]
      )
    end
    
    def collection
      MongoReflector.metadata_for(key)
    end
  end

  class Builder
    attr_accessor :current_collection
    
    def desc(klass, key = nil, &block)
      @current_collection = Collection.new(klass, key)
      MongoReflector.collections[@current_collection.key] = @current_collection
      instance_eval(&block) if block_given?
      @current_collection      
    end

    def list(*params)
      @current_collection.list_fields = build_fields(params)
    end

    def list_order(value)
      @current_collection.list_order = value
    end

    def list_page_size(value)
      @current_collection.list_page_size = value
    end

    def list_css_classes(&block)
      @current_collection.list_css_classes = block
    end
    
    def actions(params = {})
      @current_collection.actions = params
    end

    def view(*params)
      @current_collection.view_fields = build_fields(params)
    end

    def edit(field_specs)
      @current_collection.edit_fields = field_specs.map do |key, spec|
        if Array === spec
          helper = spec.shift
          args = spec
        else
          helper = spec
          args = []
        end
        Field.new(key, format: helper, args: args, collection: @current_collection)
      end
    end
    
    def view_subcollection(accessor, key)
      @current_collection.view_subcollections << Subcollection.new(accessor, key)
    end

    def _
    end
    
    private

    # Accepts a list of:
    #   :name
    #   :name, :format, option1: 'value1'
    #   :name, [:format, option1: 'value1']
    def build_fields(params_list)
      params_list = params_list.first.to_a if Hash === params_list.first
      
      params_list.map do |params|
        if Array === params
          params.flatten! if Array === params.second
          options = params.extract_options!
          name = params.first
          format = params.second
        else
          name = params
          options = {}
        end

        attributes = {format: format, collection: @current_collection}.merge(options)
        Field.new(name, attributes)
      end
    end
  end
end
