class Rabotnegi < Padrino::Application
  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers

  include Gore::EventLog::Accessor

  set :locale_path, %w(config/locales/ru.core.yml config/locales/ru.yml)

  set :uid_secret_token, 'dc00acaaa4039a2b9f9840f226022c62fd4b6eb7fa45ca289eb8727aba365d0f4ded23a3768c6c81ef2593da8fde51f9405aedcb71621a57a2de768042f336e5'
  set :message_encryptor, ActiveSupport::MessageEncryptor.new(uid_secret_token)

  set :default_builder, Gore::ViewHelpers::FormBuilder
  set :ui_cache, OpenStruct.new

  set :assets do
    @sprockets ||= Sprockets::Environment.new.tap do |env|
      env.append_path 'app/assets/javascripts'
      env.append_path 'app/assets/stylesheets'
      env.append_path 'app/assets/images'
      env.append_path 'public/vendor'
    end
  end

  set :delivery_method, :smtp => {
    address: "smtp.gmail.com",
    port: 587,
    user_name: "railsapp",
    password: "demo120107",
    authentication: :plain,
    enable_starttls_auto: true
  }
  
  set :xhr do |truth| condition { request.xhr? } end
  set :match_id do |truth| condition { Gore.object_id?(params[:id]) } end
  set :if_params do |*args| 
    mapping = args
    condition { mapping.all? { |param, matcher| matcher.key_matches?(params[param]) } } 
  end

  configure do
    Slim::Engine.set_default_options disable_escape: true, disable_capture: false
    Resque.redis.namespace = "rabotnegi:jobs"

    set :config, OpenStruct.new
    config.admin_login = 'admin'
    config.admin_password = '0000'
    config.err_max_notifications_per_hour = 2
    config.err_sender = "errors@rabotnegi.ru"
    config.err_recipients = "dmitry.sokurenko@gmail.com"
    config.original_vacancies_data_dir = Gore.root.join("tmp/vacancies_content")
    config.rabotaru_dir = Gore.root.join("tmp/rabotaru")
    config.rabotaru_period = 15
    config.default_queue = :main
    config.google_analytics_id = "UA-1612812-2" 
  end

  configure :testprod, :testui do    
    enable :logging
    disable :static
    disable :reload_templates
    disable :raise_errors
    set :delivery_method, :test
  end

  configure :development do
    register Gore::LogFilter
    set :delivery_method, :test
    set :show_exceptions, :after_handler
    
    config.rabotaru_period = 5
    
    Slim::Engine.set_default_options pretty: true
    Resque.inline = true    
  end

  configure :test do
    enable :raise_errors
    set :delivery_method, :test
    config.rabotaru_dir = Gore.root.join("tmp/test.rabotaru")
    config.original_vacancies_data_dir = Gore.root.join("tmp/test.vacancies_content")
    Resque.inline = true
  end

  helpers Gore::ControllerHelpers::Urls
  helpers Gore::ControllerHelpers::Identification
  helpers Gore::ControllerHelpers::Users

  helpers Gore::ViewHelpers::Common
  helpers Gore::ViewHelpers::Inspection
  helpers Gore::ViewHelpers::Admin
  helpers Gore::ViewHelpers::Formatting
  helpers Gore::ViewHelpers::Editing
  helpers Gore::ViewHelpers::Layout
  helpers Gore::ViewHelpers::Collections

  ##
  # Caching support
  #
  # register Padrino::Cache
  # enable :caching
  #
  # set :cache, Padrino::Cache::Store::Memcache.new(::Memcached.new('127.0.0.1:11211', :exception_retry_limit => 1))
  # set :cache, Padrino::Cache::Store::Memcache.new(::Dalli::Client.new('127.0.0.1:11211', :exception_retry_limit => 1))
  # set :cache, Padrino::Cache::Store::Redis.new(::Redis.new(:host => '127.0.0.1', :port => 6379, :db => 0))
  # set :cache, Padrino::Cache::Store::Memory.new(50)
  # set :cache, Padrino::Cache::Store::File.new(Padrino.root('tmp', app_name.to_s, 'cache')) # default choice
  # 


  # 
  # Filters & error handlers
  # 

  error 500..599 do
    raise env["sinatra.error"] if Gore.env.development?
    
    Gore::Err.register route.named || request.path, env["sinatra.error"],
      params: params.except("captures"),
      url: request.url, 
      verb: request.request_method,
      session: session.to_hash.except('flash'),
      flash: flash.to_hash,
      request_headers: env.select { |k,v| k.starts_with?("HTTP_") },
      response_headers: headers
        
    raise env["sinatra.error"]
  end
  
  before { settings.set :last_instance, self } if Gore.env.test?
  before { logger.info "Start #{request.path}" } if Gore.env.development?
  # before { `touch #{Padrino.root("app/app.rb")}` } if Gore.env.development?

  ##
  # Overrides
  #
  
  # Overriden to enable string/symbol access to all (path & query) parameters.
  def indifferent_hash
    Gore::Mash.new
  end  

  # Fix the totally broken view engines.
  def concat_content(content)
    content
  end

  # def block_is_template?(block)
  #   false
  # end
  
  # def form_tag(url, options={}, &block)
  #   desired_method = options[:method]
  #   data_method = options.delete(:method) if options[:method].to_s !~ /get|post/i
  #   options.reverse_merge!(:method => "post", :action => url)
  #   options[:enctype] = "multipart/form-data" if options.delete(:multipart)
  #   options["data-remote"] = "true" if options.delete(:remote)
  #   options["data-method"] = data_method if data_method
  #   options["accept-charset"] ||= "UTF-8"
  #   inner_form_html  = hidden_form_method_field(desired_method)
  #   inner_form_html += capture_html(&block).to_s
  #   content_tag(:form, inner_form_html, options)
  # end  
  
  def label_tag(name, *args, &block)
    options = args.extract_options!
    options[:caption] = args.first if args.any?
    super(name, options, &block)
  end
  
  def select_tag(name, options={})
    options[:options] = send(options[:options]) if options[:options].is_a?(Symbol)
    options[:grouped_options] = send(options[:grouped_options]) if options[:grouped_options].is_a?(Symbol)   
    super
  end

  def capture_html(*args, &block)
    block_given? && block.call(*args)
  end
       
  def dump_errors!(boom)
    return super unless Gore.env.in?('development', 'testui')
    return super unless Array === boom.backtrace

    boom.backtrace.reject! { |line| line =~ /thin|thor|eventmachine|rack|barista|http_router|tilt/ }
    boom.backtrace.map! { |line| line.gsub(Padrino.root, '') }
    super
  end
  
end
