# Defines our constants
PADRINO_ENV  = ENV["PADRINO_ENV"] ||= ENV["RACK_ENV"] ||= "development"  unless defined?(PADRINO_ENV)
PADRINO_ROOT = File.expand_path('../..', __FILE__) unless defined?(PADRINO_ROOT)

# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default, PADRINO_ENV)

##
# Enable devel logging
#
# Padrino::Logger::Config[:development] = { :log_level => :devel, :stream => :stdout }
# Padrino::Logger.log_static = true
#
Padrino::Logger::Config[:testprod] = { :log_level => :info, :stream => :to_file }

silence_warnings { Sass::Engine::DEFAULT_OPTIONS = Sass::Engine::DEFAULT_OPTIONS.dup.merge(style: :compact) }  

##
# Add your before load hooks here
#
Padrino.before_load do
  I18n.locale = 'ru'
  # I18n.backend.load_translations Padrino.root("config/locales/ru.core.yml")
  # I18n.backend.load_translations Padrino.root("config/locales/ru.yml")
end

##
# Add your after load hooks here
#
Padrino.after_load do
end

Padrino.load!
