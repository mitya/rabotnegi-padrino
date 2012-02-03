#!/usr/bin/env rackup
# encoding: utf-8

# This file can be used to start Padrino,
# just execute it from the command line.

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
