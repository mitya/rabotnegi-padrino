require 'test_helper'

unit_test Salary do
  setup do
    @between_1000_2000 = Salary.make(:min => 1000, :max => 2000)
    @above_1000 = Salary.make(:min => 1000)
    @below_1000 = Salary.make(:max => 1000)
    @exactly_1000 = Salary.make(:exact => 1000)
  end
  
  test "create with one attribute" do
    actual = Salary.make(:exact => 1000)
		expected = Salary.make; expected.exact = 1000
		assert_equal expected, actual
  end
  
  test "create with many attributes" do
    actual = Salary.make(:min => 1000, :negotiable => false, :currency => :usd)
    expected = Salary.make; expected.min = 1000; expected.currency = :usd; expected.negotiable = false
		assert_equal expected, actual    
  end
  
  test "parse exact value" do
    assert_equal @exactly_1000, Salary.parse('1000')
  end
  
  test "parse max value" do
    assert_equal @below_1000, Salary.parse('<1000')
    assert_equal @below_1000, Salary.parse('до 1000')
  end
  
  test "parse min value" do
    assert_equal @above_1000, Salary.parse('от 1000')
    assert_equal @above_1000, Salary.parse('1000+')
  end
  
  test "parse range" do
    assert_equal @between_1000_2000, Salary.parse('1000-2000')
  end

  test "parse with bad input" do
    assert_equal Salary.new, Salary.parse('тыщща')
  end
  
  test "to_s" do
    assert_equal '1000—2000 р.', @between_1000_2000.to_s
  end
  
  test "==" do
    assert_equal Salary.make(:exact => 1000, :currency => :usd), Salary.make(:exact => 1000, :currency => :usd)
  end
  
  test "convert_currency" do
    salary = Salary.make(:exact => 1000, :currency => :usd)
    salary.convert_currency(:rub)
    
    assert_equal 31_000, salary.exact
    assert_equal :rub, salary.currency
  end
  
  test "text=" do
    salary = Salary.make(exact: 1000)
    salary.text = "от 5000"
    assert_equal Salary.make(min: 5000), salary
  end
end
