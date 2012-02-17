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

require 'resque/server'
map "/admin/resque" do
  run Resque::Server.new
end

map '/' do
  run Padrino.application
end
