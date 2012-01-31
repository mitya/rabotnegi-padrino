require 'test_helper'

unit_test Industry do
  test "search by one of external ids" do 
    assert_equal :finance, Industry.find_by_external_ids(2001, 2003, 2, 9, 2003)
  end
end