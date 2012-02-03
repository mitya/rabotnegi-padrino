require 'test_helper'

unit_test Gore::Stubbing do
  dummy = temp_class do
    def self.foo(param)
      "original #{param}"
    end
  end
  
  test "stubbing/unstubbing" do
    assert_equal "original passed", dummy.foo("passed")

    Gore::Stubbing.stub(dummy, :foo) { |param| "patched #{param}" }
    assert_equal "patched passed", dummy.foo("passed")    

    Gore::Stubbing.unstub_all
    assert_equal "original passed", dummy.foo("passed")
  end
end
