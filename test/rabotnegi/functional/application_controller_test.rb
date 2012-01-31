require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  tests TestController

  test "default locale" do
    get :locale
    assert_equal :ru, I18n.locale
  end
  
  test "error notifications" do
    $test_error_reporting_enabled = true
    Err.delete_all
    
    assert_raise ArgumentError do
      get :error
    end
    
    assert_equal 1, Err.count
    assert_emails 1

    puts response.code
  end
  
  teardown do
    $test_error_reporting_enabled = false
  end
end


class CurrentUserTest < ActionController::TestCase
  tests TestController
  
  setup do
    @user_1 = User.create!
    @user_2 = User.create!(agent: "test browser", ip: "2.2.2.2")
    @user_3 = User.create!
  end

  test "current_user can find the user when a valid user_id cookie is provided" do
    @request.cookies[:uid] = ApplicationController::Encryptor.encrypt(@user_1.id)

    get :nope
    
    assert_equal @user_1, @controller.send(:current_user)
  end

  test "current_user can find the user when the same user agent and ip address exist" do
    @request.remote_addr = "2.2.2.2"
    @request.user_agent = "test browser"

    get :nope
    
    assert_equal @user_2, @controller.send(:current_user)
  end

  test "when current_user! can't find a user it creates a new one" do
    get :nope
    
    current_user = @controller.send(:current_user!)
    
    assert_not_nil current_user
    assert ! [@user_1, @user_2, @user_3].include?(current_user)
    assert_equal @request.remote_ip, current_user.ip
    assert_equal @request.user_agent, current_user.agent
  end
end
