#!/usr/bin/env rackup

require File.expand_path("../config/boot.rb", __FILE__)

Rack::Server.middleware["development"] = [
  [Rack::ContentLength],
  [Rack::Chunked],
  [Rack::ShowExceptions], 
  [Rack::Lint]
]

map '/rabotnegi/assets' do
  use Rack::CommonLogger
  run Rabotnegi.assets
end

map '/' do
  run Padrino.application
end
