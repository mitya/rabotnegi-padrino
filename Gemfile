source :rubygems

# Server requirements (defaults to WEBrick)
# gem 'thin'
# gem 'mongrel'

# Project requirements
gem 'rake'
gem 'sinatra-flash', :require => 'sinatra/flash'

# Component requirements
gem 'sass'
gem 'slim'
gem 'mongoid'
gem 'bson_ext', :require => "mongo"

# Test requirements
gem 'mocha', :group => "test"
gem 'minitest', "~>2.6.0", :require => "minitest/autorun", :group => "test"
gem 'rack-test', :require => "rack/test", :group => "test"

# Padrino Stable Gem
gem 'padrino', '0.10.5'

# Or Padrino Edge
# gem 'padrino', :git => 'git://github.com/padrino/padrino-framework.git'

# Or Individual Gems
# %w(core gen helpers cache mailer admin).each do |g|
#   gem 'padrino-' + g, '0.10.5'
# end

gem "barista"
# gem 'resque'
# gem 'rmagick' # for captcha
# gem "galetahub-simple_captcha", :require => "simple_captcha"
gem "unicode_utils" # for cyrillic parameterization
# gem "syslog-logger", :require => 'syslog_logger'
# gem "daemons"

# gem 'rails'
# gem 'sqlite3'
# gem "bson_ext" # for mongoid
# gem "mongoid"
# gem 'slim'
# gem 'sass-rails'
# gem "therubyracer" # weird bugs otherwise

group :development, :test do
  gem 'capistrano'
#   gem 'ruby-prof'
#   gem 'test-unit'
#   gem "factory_girl"
#   gem 'capybara'
#   gem 'capybara-webkit'
#   gem 'launchy'
#   gem 'turn', :require => false
  gem 'thin'
#   gem 'mocha'
end

# group :assets do
#   gem 'coffee-rails'
#   gem 'uglifier'
# end
