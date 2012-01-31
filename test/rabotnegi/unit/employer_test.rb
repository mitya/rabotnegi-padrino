require 'test_helper'

unit_test Employer do
  setup do
    @microsoft = Employer.new(:name=>'Microsoft', :login => 'ms', :password => '123', :password_confirmation => '123')
  end
  
  test "creation" do
    assert @microsoft.valid?
  end
  
  test "creation without password" do
    @bad_microsoft = Employer.new(:name => 'Microsoft', :login => 'ms')
    assert !@bad_microsoft.valid?
    assert @bad_microsoft.errors[:password].any?
  end    
end
