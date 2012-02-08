source :rubygems

gem 'padrino', '0.10.6.c'
gem 'rake'
gem 'sinatra-flash', require: 'sinatra/flash'
gem 'sass'
gem 'slim'
gem 'haml'
gem 'erubis'
gem 'coffee-script'
gem 'sprockets'
gem 'mongoid'
gem 'bson_ext', require: "mongo"
gem "daemons"

gem "unicode_utils"
gem 'resque'
gem 'rmagick'
gem "syslog-logger", require: 'syslog_logger'
gem "sanitize"

# gem "galetahub-simple_captcha", :require => "simple_captcha"
# gem "therubyracer" # weird bugs otherwise

group :test do
  gem 'mocha'
  gem 'minitest', require: "minitest/autorun"
  gem 'rack-test', require: "rack/test"
  gem "factory_girl"
  gem 'turn'
  gem 'webrat'
  # gem 'capybara'
  # gem 'capybara-webkit'
end

group :development, :test do
  gem 'capistrano'
  gem 'thin'
end
