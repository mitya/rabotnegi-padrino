require 'test_helper'

describe "Helpers" do
  test "web_id" do
    vacancy = make Vacancy
    get "/tests/noop"
    
    assert_equal "v-#{vacancy.id}", helpers.web_id(vacancy)
    assert_equal "v-#{vacancy.id}-details", helpers.web_id(vacancy, :details)
  end
end
