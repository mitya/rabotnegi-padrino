require 'test_helper'
require 'rails/performance_test_help'

# Profiling results for each test method are written to tmp/performance.
class BrowsingTest < ActionDispatch::PerformanceTest
  self.profile_options = ActiveSupport::Testing::Performance::DEFAULTS.merge(:metrics=>[:wall_time])

  def test_vacancies
    10.times { get '/vacancies/msk' }
  end
end
