require 'test_helper'

unit_test 'Gore::ApplicationModel' do
  test 'default salary' do
    vacancy = make Vacancy
    
    assert_respond_to Vacancy, :get
    assert_respond_to Employer, :get
    
    assert Vacancy.singleton_methods(false).include?(:get)
    assert Employer.singleton_methods(false).exclude?(:get)
  end
end
