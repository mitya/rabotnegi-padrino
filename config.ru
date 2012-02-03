#!/usr/bin/env rackup
# encoding: utf-8

# This file can be used to start Padrino,
# just execute it from the command line.

require File.expand_path("../config/boot.rb", __FILE__)

map '/rabotnegi/assets' do
  run Rabotnegi.assets
end

run Padrino.application
map '/' do
  run Padrino.application
end
