# Defines our constants
RACK_ENV = ENV['RACK_ENV'] ||= 'development'  unless defined?(RACK_ENV)
PADRINO_ROOT = File.expand_path('../..', __FILE__) unless defined?(PADRINO_ROOT)


# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'

# bundler_group = ENV["RACK_ENV"]
# bundler_group = "test" if bundler_group == "testui"
Bundler.require(:default, RACK_ENV)

# Padrino::Logger::Config[:production] = { :log_level => :info, :stream => :to_file }
# Padrino::Logger::Config[:testprod] = { :log_level => :info, :stream => :stdout }
# Padrino::Logger::Config[:testui] = { :log_level => :info, :stream => :stdout }
#
# silence_warnings { Sass::Engine::DEFAULT_OPTIONS = Sass::Engine::DEFAULT_OPTIONS.dup.merge(style: :compact) }

Padrino.before_load do
  # I18n.locale = 'ru'
end

Padrino.after_load do
  Gore::SassFunctions.register
end

Padrino.load!
