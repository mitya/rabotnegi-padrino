require 'test_helper'

unit_test Resume do
  setup do
    @resume = Resume.new
  end
  
  test "name format" do
    assert_equal 'Mitya', Resume.new(:fname => 'Mitya').name
    assert_equal 'Mitya Ivanov', Resume.new(:fname => 'Mitya', :lname => 'Ivanov').name
  end
end
