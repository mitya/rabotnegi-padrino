require 'test_helper'

describe "Controllers" do
  test "default locale" do
    gets "/tests/noop"
    I18n.locale.must_equal :ru
  end

  test "error notifications" do
    Gore::Err.delete_all
    
    assert_raises ArgumentError do
      gets "/tests/error"
    end
    
    Gore::Err.count.must_eq 1
    assert_emails 1
  end
  
  test "sitemap" do
    get "sitemap.xml"    
    response.must_be :ok?
    response.body.must_match "/vacancies/msk/office"
    response.body.must_match "/vacancies/spb/it"
  end
  
  describe "current user" do
    setup do
      @user_1 = User.create!(ip: "2.2.2.1")
      @user_2 = User.create!(agent: "test browser", ip: "2.2.2.2")
      @user_3 = User.create!(ip: "2.2.2.3")
    end

    it "find the user when a valid user_id cookie is provided" do
      set_cookie "uid=#{URI.encode_www_form_component app.message_encryptor.encrypt_and_sign(@user_1.id)}"
      gets "/tests/noop"
      app.last_instance.current_user.must_equal @user_1
    end

    it "find the user by the user agent and ip address" do
      gets "/tests/noop", {}, {"REMOTE_ADDR" => "2.2.2.2", "HTTP_USER_AGENT" => "test browser"}
      app.last_instance.current_user.must_eq @user_2
    end
    
    it "create a new one when can't find an existing" do
      gets "/tests/noop", {}, {"REMOTE_ADDR" => "3.3.3.3", "HTTP_USER_AGENT" => "another browser"}
      current_user = app.last_instance.current_user!

      current_user.wont_be_nil
      current_user.wont_be :in?, [@user_1, @user_2, @user_3]
      current_user.ip.must_eq "3.3.3.3"
      current_user.agent.must_eq "another browser"
    end    
  end
end
