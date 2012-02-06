require 'net/http'

module Gore
  def logger
    @logger ||= Logger.new
  end
  
  def http
    @http ||= HttpClient.new
  end
  
  def json
    @json ||= Json.new
  end

  module RandomHelpers
    def id(array)
      results = array ? array.map(&:id) : []
      results = results.map(&:to_s) if results.first.is_a?(BSON::ObjectId)
      results
    end
    
    # f("fixed1", "fixed2", conditional1: true, conditional2: false) => "fixed1 fixed2 conditional1"
    def css_classes_for(*args)
      return nil if args.empty?

      conditions = args.extract_options!
      classes = args.dup
      conditions.each { |clas, condition| classes << clas if condition }
      classes.join(" ")
    end
    
    def inspection(title, *args)
      options = args.extract_options!
      options.reject! { |k,v| v.blank? }
      options = options.map { |k,v| "#{k}=#{inspect_value(v)}" }.join(',')
      args.map! { |arg| Array === arg ? arg.join('-') : arg }
      args = args.join(',')
      string = [args, options].reject(&:blank?).join(' ')
      inspection = "{#{string}}"
    end
    
    def inspect_value(value)
      case value
        when Proc then "Proc"
        when Hash then inspect_hash(value)
        when Array then inspect_array(value)
        when nil then "∅"
        when Time then value.xmlschema
        else value
      end
    end
    
    def inspect_hash(hash)
      (hash || {}).map { |key, val| "#{key}: #{inspect_value(val)}" }.join(", ")
    end
    
    def inspect_array(array)
      (array || []).join(", ")
    end
    
    def reformat_caller(string)
      file, line, method = string.match(/(\w+\.rb):(\d+):in `(\w+)'/).try(:captures)
      "#{file}::#{method}::#{line}"
    end    
  end
  
  module Jobs
    def enqueue(klass, method, *args)
      # Resque.enqueue_to(:main, ProxyWorker, args)
      Log.info "Job scheduled #{klass}.#{method}#{args.inspect}"
      Resque::Job.create('main', 'Gore::Jobs::Worker', klass.to_s, method.to_s, args)
    end

    class Worker
      def self.perform(klass, method, args)
        Log.info "Job started #{klass}.#{method}#{args.inspect}"
        klass.constantize.send(method, *args)
        Log.info "Job completed #{klass}.#{method}#{args.inspect}"
      end
    end
  end
  
  module Strings
    def time_stamp
      time = Time.current
      time.strftime("%Y%m%d_%H%M%S_#{time.usec}")
    end
    
    def date_stamp
      time = Time.current
      time.strftime("%Y%m%d")
    end
  
    def format_error(exception)
      "#{exception.class} - #{exception.message}"
    end

    def format_error_and_stack(exception)
        # logger.error Gore.backtrace_cleaner.clean(exception.backtrace).join("\n")
      format_error(exception) + "\n#{exception.backtrace.join("\n")}"
    end    
  end
    
  module Server
    def disk_usage(mount_point = '/')
      output = `df #{mount_point}`
      lines = output.split("\n")
      value = lines.second.split.at(-2).to_i
      value
    rescue
      nil
    end
  
    def memory_free
      output = `free -m`
      lines = output.split("\n")
      value = lines.second.split.at(3).to_i
      value
    rescue 
      nil
    end    
  end

  class Logger
    undef :silence
    LOG_METHODS = %w(debug info warn error fatal unknown).pluck(:to_sym)
    ALL_METHODS = LOG_METHODS + %w(silence level level=).pluck(:to_sym)
    
    def method_missing(selector, *args, &block)
      if ALL_METHODS.include?(selector)
        Kernel.puts(args.first) if LOG_METHODS.include?(selector) && $log_to_stdout
        Padrino.logger.send(selector, *args, &block)
      else
        super
      end      
    end
    
    def trace(*args)
      debug(*args)
    end
  end

  class HttpClient
    def get(url)
      Log.trace "HTTP GET #{url}"
      Net::HTTP.get(URI.parse(url))      
    end
  end
  
  class Json
    def decode(data)
      ActiveSupport::JSON.decode(data)
    end    
  end

  extend self, Server, Strings, Jobs, RandomHelpers
  
  def env
    ActiveSupport::StringInquirer.new(Padrino.env.to_s)
  end
  
  def root
    Pathname(Padrino.root)
  end
  
  def self.method_missing(selector, *args, &block)
    return const_get(selector) if const_defined?(selector)
    super
  end
end

Log = Gore.logger
Http = Gore.http
