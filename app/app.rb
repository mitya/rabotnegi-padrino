class Rabotnegi < Padrino::Application
  register SassInitializer
  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers

  enable :sessions
  set :xhr do |truth| condition { request.xhr? } end
  set :show_exceptions, :after_handler
  set :uid_secret_token, 'dc00acaaa4039a2b9f9840f226022c62fd4b6eb7fa45ca289eb8727aba365d0f4ded23a3768c6c81ef2593da8fde51f9405aedcb71621a57a2de768042f336e5'

  configure :testprod do    
    enable :logging
    disable :show_exceptions
    disable :static
    disable :reload_templates
  end


  ## Logger

  class ::Padrino::Logger
    FILTERED_LOG_ENTRIES = [
      "Served asset", 'Started GET "/assets/',
      "['system.namespaces'].find({})",
    ]
  
    def write(message = nil)
      return if String === message && FILTERED_LOG_ENTRIES.any? { |pattern| message.include?(pattern) }
      self << message
    end  
  end if Gore.env.development?

   
  ## Barista

  register Barista::Integration::Sinatra
  
  def Barista.debug(message) end
  
  Barista.configure do |c|
    c.root = Gore.root.join("app", "javascripts")
    c.output_root = Gore.root.join("public", app_name.to_s, "javascripts")
  end    


  ## Slim

  Slim::Engine.set_default_options disable_escape: true, disable_capture: false

  
  ##
  # Caching support
  #
  # register Padrino::Cache
  # enable :caching
  #
  # You can customize caching store engines:
  #
  #   set :cache, Padrino::Cache::Store::Memcache.new(::Memcached.new('127.0.0.1:11211', :exception_retry_limit => 1))
  #   set :cache, Padrino::Cache::Store::Memcache.new(::Dalli::Client.new('127.0.0.1:11211', :exception_retry_limit => 1))
  #   set :cache, Padrino::Cache::Store::Redis.new(::Redis.new(:host => '127.0.0.1', :port => 6379, :db => 0))
  #   set :cache, Padrino::Cache::Store::Memory.new(50)
  #   set :cache, Padrino::Cache::Store::File.new(Padrino.root('tmp', app_name.to_s, 'cache')) # default choice
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
