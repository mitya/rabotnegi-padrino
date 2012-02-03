class Rabotnegi < Padrino::Application
  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers

  set :xhr do |truth| condition { request.xhr? } end
  set :show_exceptions, :after_handler
  set :uid_secret_token, 'dc00acaaa4039a2b9f9840f226022c62fd4b6eb7fa45ca289eb8727aba365d0f4ded23a3768c6c81ef2593da8fde51f9405aedcb71621a57a2de768042f336e5'
  set :locale_path, %w(config/locales/ru.core.yml config/locales/ru.yml)
  set :assets do
    env = Sprockets::Environment.new
    env.append_path 'app/assets/javascripts'
    env.append_path 'app/assets/stylesheets'
    env.append_path 'public/vendor'
    env
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

  configure :testprod do    
    enable :logging
    disable :show_exceptions
    disable :static
    disable :reload_templates
  end

  configure :development do
    register Gore::LogFilter
    config.rabotaru_period = 5
    Slim::Engine.set_default_options pretty: true
    Resque.inline = true    
  end

  configure :test do
    config.rabotaru_dir = Gore.root.join("tmp/rabotaru.test")
    config.original_vacancies_data_dir = Gore.root.join("tmp/vacancies_content.test")
    Resque.inline = true
  end

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

  ##
  # Application configuration options
  #
  # set :raise_errors, true       # Raise exceptions (will stop application) (default for test)
  # set :dump_errors, true        # Exception backtraces are written to STDERR (default for production/development)
  # set :logging, true            # Logging in STDOUT for development and file for production (default only for development)
  # set :public_folder, "foo/bar" # Location for static assets (default root/public)
  # set :reload, false            # Reload application files (default in development)
  # set :default_builder, "foo"   # Set a custom form builder (default 'StandardFormBuilder')
  # set :locale_path, "bar"       # Set path for I18n translations (default your_app/locales)
  # disable :sessions             # Disabled sessions by default (enable if needed)
  # disable :flash                # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
  # layout  :my_layout            # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
  #
  
end
