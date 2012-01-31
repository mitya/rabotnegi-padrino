require 'test_helper'

unit_test "Domain initialization" do
  test "industry data loading" do
    assert Industry.all.size > 10
    assert Industry.popular.size > 5
    assert Industry.other.size > 5    
  end
  
  test "city data loading" do
    assert_equal 5, City.all.size
  end
end