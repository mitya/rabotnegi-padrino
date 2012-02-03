require 'test_helper'

unit_test Gore::Err do
  ERROR_DATA = {
    url: "http://rabotnegi.test/vacancies/1234", 
    verb: "GET",
    session: {session_var_1: 100, session_var_2: 200}, 
    params: {parameter_1: 'parameter_1_value'}, 
    cookies: ["uid"],
    request_headers: {'Header-1' => '100', 'Header-2' => '200'},
    response_headers: {}
  }

  setup do
    # ActionMailer::Base.deliveries.clear
    Gore::Err.delete_all
    @exception = ArgumentError.new("test error message")
    @exception.set_backtrace ["stack line 1", "stack line 2", "stack line 3"]
  end
  
  test "register a web error" do
    err = Gore::Err.register("vacancies/show", @exception, ERROR_DATA)
    
    assert_equal 1, Gore::Err.count
    assert_equal "test error message", Gore::Err.last.exception_message
    assert_equal "ArgumentError", Gore::Err.last.exception_class
    assert_equal ["stack line 1", "stack line 2", "stack line 3"].join("\n"), Gore::Err.last.backtrace

    # assert_emails 1
    # assert_match "test error message", ActionMailer::Base.deliveries.last.subject
  end

  test "register an error when there were too many other errors this hour" do
    Se.err_max_notifications_per_hour.times { Gore::Err.create!(ERROR_DATA.merge(exception_class: "ArgumentError")) }

    err = Gore::Err.register("vacancies/show", @exception, ERROR_DATA)
    assert_equal Se.err_max_notifications_per_hour + 1, Gore::Err.count
    assert_emails 0
  end
end
