require 'test_helper'

unit_test SortExpressions do
  test "decode_order_to_mongo" do
    assert_equal [["date", Mongo::ASCENDING]], SortExpressions.decode_order_to_mongo("date")
    assert_equal [["date", Mongo::DESCENDING]], SortExpressions.decode_order_to_mongo("-date")
  end
end
