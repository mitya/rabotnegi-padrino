require 'test_helper'

describe "Gore::Err mailer" do
  test "notification" do
    get "/tests/noop" # hack to load helpers
    
    err = Gore::Err.new(
      controller: "vacancies", 
      action: "show", 
      url: "http://rabotnegi.test/vacancies/1234", 
      verb: "GET",
      host: "rabotnegi.test", 
      time: Time.current,
      session: {session_var_1: 100, session_var_2: 200}, 
      params: {parameter_1: 'parameter_1_value'}, 
      exception_class: 'ApplicationError',
      exception_message: "a test thing",
      cookies: ["uid"],
      backtrace: "stack line 1\nstack line 2\nstack line 3",
      request_headers: {'Header-1' => '100', 'Header-2' => '200'},
      response_headers: {}
    )
 
    email = err.notify
    body = email.body.to_s
 
    assert_equal [Rabotnegi.config.err_recipients], email.to
    assert_equal [Rabotnegi.config.err_sender], email.from
    assert_equal "[rabotnegi.ru errors] vacancies/show - ApplicationError - a test thing", email.subject
    assert_match "GET http://rabotnegi.test/vacancies/1234", body
    assert_match "parameter_1", body
    assert_match "parameter_1_value", body
    assert_match "stack line 1", body
    assert_match "stack line 2", body
  end
end
