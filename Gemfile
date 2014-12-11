source 'https://rubygems.org'

gem 'rake'
gem 'sinatra-flash', require: 'sinatra/flash'
gem 'sass'
gem 'slim'
gem 'haml'
gem 'erubis'
gem 'coffee-script'
gem 'sprockets'
gem 'mongoid'
gem "daemons"

gem "unicode_utils"
gem 'resque'
gem 'rmagick'
gem "syslog-logger"
gem "sanitize"

gem 'padrino', '0.12.4'

# gem "therubyracer" # weird bugs otherwise

group :test do
  gem 'mocha'
  gem 'minitest', require: "minitest/autorun"
  gem 'rack-test', require: "rack/test"
  gem "factory_girl"
  gem 'turn'
  gem 'webrat'
  gem 'capybara'
  # gem 'capybara-webkit'
end

group :development, :test do
  gem 'capistrano'
  gem 'thin'
end
