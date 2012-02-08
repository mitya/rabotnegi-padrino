PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path('../../config/boot', __FILE__)
# ENV["RAILS_ENV"] = ENV["X_RAILS_ENV"] || "test"

require "support/mocks"
require "support/factories"

class MiniTest::Spec
  include Mocha::API
  include Rack::Test::Methods
  include Webrat::Matchers
  include Gore::Testing::Helpers
  include Gore::Testing::RackHelpers
  include Gore::Testing::Assertions
  extend Gore::Testing::Cases

  class << self
    alias test it
    alias setup before
    alias teardown after
  end

  alias response last_response
  
  teardown do
    Vacancy.delete_all
    User.delete_all
  end unless Gore.env.testprod? || Gore.env.testui?

  def app
    Rabotnegi.tap { |app| }
  end

  def helpers
    app.last_instance
  end

  def response_body
    last_response.body
  end  
end

module MiniTest::Expectations
  infect_an_assertion :assert_equal, :must_eq
end

module Kernel
  include Gore::Testing::Globals
  alias unit_test describe
end

Webrat.configure do |config|
  config.mode = :rack
end

Turn.config do |c|
  c.format = :pretty # outline pretty dotted progress marshal cue
end
