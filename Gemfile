source :rubygems

# Project requirements
gem 'padrino', '0.10.5'
gem 'rake'
gem 'sinatra-flash', :require => 'sinatra/flash'
gem 'sass'
gem 'slim'
gem 'sprockets'
gem 'mongoid'
gem 'bson_ext', :require => "mongo"
gem "unicode_utils"
gem 'coffee-script'
gem "uglifier"
# gem 'resque'
# gem 'rmagick' # for captcha
# gem "galetahub-simple_captcha", :require => "simple_captcha"
# gem "syslog-logger", :require => 'syslog_logger'
# gem "daemons"
# gem "therubyracer" # weird bugs otherwise

group :test do
  gem 'mocha'
  gem 'minitest', :require => "minitest/autorun"
  gem 'rack-test', :require => "rack/test"  
end

group :development, :test do
  gem 'capistrano'
  gem 'thin'
  # gem 'ruby-prof'
  # gem "factory_girl"
  # gem 'capybara'
  # gem 'capybara-webkit'
  # gem 'launchy'
  # gem 'turn', :require => false
end
