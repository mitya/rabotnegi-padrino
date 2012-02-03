PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path('../../config/boot', __FILE__)
# ENV["RAILS_ENV"] = ENV["X_RAILS_ENV"] || "test"

require "support/mocks"
require "support/factories"

class MiniTest::Spec
  include Mocha::API
  include Rack::Test::Methods
  include Gore::Testing::Helpers
  include Gore::Testing::Assertions
  extend Gore::Testing::Cases

  def app
    Rabotnegi.tap { |app| }
  end

  class << self
    alias :test :it
    alias :setup :before
    alias :teardown :after
  end

  teardown do
    Vacancy.delete_all
    User.delete_all
  end unless Gore.env.testprod? || Gore.env.testui?
end

module Kernel
  include Gore::Testing::Globals
  alias :unit_test :describe
end
