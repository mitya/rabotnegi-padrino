require 'test_helper'

unit_test Currency do
  test "convertion" do
    assert_in_delta 73, Currency.convert(100, :usd, :eur), 1
    assert_equal 1, Currency.convert(31, :rub, :usd)
  end
  
  test "convertion to the same currency" do
    assert_equal 100, Currency.convert(100, :usd, :usd)
    assert_equal 100, Currency.convert(100, :rub, :rub)
  end
end