require 'test_helper'

class ErrMailerTest < ActionMailer::TestCase
  test "notification" do
    @err = Gore::Err.new(
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
 
    email = Gore::Err::Mailer.notification(@err)
    body = Gore.unescape_action_mailer_stuff(email.body.to_s)
 
    assert_equal [Se.err_recipients], email.to
    assert_equal [Se.err_sender], email.from
    assert_equal "[rabotnegi.ru errors] vacancies/show - ApplicationError - a test thing", email.subject
    assert_match "GET http://rabotnegi.test/vacancies/1234", body
    assert_match "parameter_1", body
    assert_match "parameter_1_value", body
    assert_match "stack line 1", body
    assert_match "stack line 2", body
  end
end
