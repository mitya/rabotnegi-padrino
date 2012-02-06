require 'test_helper'

describe "Controllers" do
  test "default locale" do
    get "/tests/noop"
    assert_equal :ru, I18n.locale
  end

  test "error notifications" do
    Gore::Err.delete_all
    
    assert_raises ArgumentError do
      get "/tests/error"
    end
    
    assert_equal 1, Gore::Err.count
    # assert_emails 1
  end
  
  describe "current user" do
    setup do
      @user_1 = User.create!(ip: "2.2.2.1")
      @user_2 = User.create!(agent: "test browser", ip: "2.2.2.2")
      @user_3 = User.create!(ip: "2.2.2.3")
    end

    test "current_user can find the user when a valid user_id cookie is provided" do
      set_cookie "uid=#{URI.encode_www_form_component app.message_encryptor.encrypt(@user_1.id)}"
      get "/tests/noop"
    
      assert_equal @user_1, app.last_instance.current_user
    end

    test "current_user can find the user when the same user agent and ip address exist" do
      get "/tests/noop", {}, {"REMOTE_ADDR" => "2.2.2.2", "HTTP_USER_AGENT" => "test browser"}
    
      assert_equal @user_2, app.last_instance.current_user
    end
    
    test "when current_user! can't find a user it creates a new one" do
      get "/tests/noop", {}, {"REMOTE_ADDR" => "3.3.3.3", "HTTP_USER_AGENT" => "another browser"}
      current_user = app.last_instance.current_user!
    
      assert current_user
      assert ! [@user_1, @user_2, @user_3].include?(current_user)
      assert_equal "3.3.3.3", current_user.ip
      assert_equal "another browser", current_user.agent
    end    
  end
end
