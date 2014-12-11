##
# Comments
# * data, extra attributes are not stored when they are nil
# * severity is not stored if it is :info
# * updated_at is not stored
# * created_at is explicitely stored, while it can be extracted from _id
# 
class Gore::EventLog
  class << self
    def write(source, event, severity = :info, data = nil, extra = nil)
      return nil unless severity_logged?(severity)
      item = Item.new source: source, event: event
      
      # don't store those attributes if they have default values
      item.severity = severity unless severity.nil? || severity.to_s == 'info'
      item.data = data unless data.nil?
      item.extra = extra unless extra.nil?
      
      item.save!

      puts "Event: #{item.as_string}" if $log_to_stdout

      item
    end
    
    %w(debug info warn error fatal).each do |severity|
      class_eval <<-ruby
        def #{severity}(source, event, data = nil, extra = nil)
          write(source, event, :#{severity}, data, extra)
        end
      ruby
    end
    
    SEVERITY_LEVELS = { debug: Logger::DEBUG, info: Logger::INFO, warn: Logger::WARN, error: Logger::ERROR }
    
    def severity_logged?(item_severity)
      item_severity_level = SEVERITY_LEVELS[item_severity] || -1
      item_severity_level >= Log.level
    end
  end  

  module Accessor
    def self.included(klass)
      klass.class_eval do
        def self.log
          @log ||= Writer.for_class(self)
        end
      end
    end
    
    def log
      self.class.log
    end    
  end
  
  class Writer
    attr_accessor :source
    
    def initialize(source)
      @source = source.to_s
    end

    METHODS = %w(write debug info warn error)

    def method_missing(selector, *args, &block)
      if METHODS.include?(selector.to_s)
        Gore::EventLog.send(selector, source, *args, &block)
      else
        super
      end
    end
    
    def self.for_class(klass)
      new log_key_for(klass)
    end
    
    def self.log_key_for(klass)
      klass.name.underscore.parameterize('_')
    end
  end

  class Item < Gore::ApplicationModel
    store_in collection: "sys.events"

    field :source
    field :event, type: String
    field :severity, type: Symbol
    field :data
    field :extra, type: Hash

    no_update_tracking

    def time
      id.generation_time
    end

    def severity
      super || :info
    end
    
    def as_string
      "#{time} #{source}::#{event} (#{Gore.inspect_value(data)})"
    end
    
    def to_s
      "#{source}::#{event}@#{time}"
    end
    
    class << self
      def query(options)
        return self unless options[:q].present?
        
        source, event = options[:q].split('::')
        
        conditions = {}
        conditions[:source] = /^#{source}/ if source.present?
        conditions[:event] = /^#{event}/ if event.present?
        
        where(conditions)
      end      
    end
  end
end
