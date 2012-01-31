class ErrMailer < ActionMailer::Base
  default from: Se.err_sender
  helper :application, :format

  def notification(err)
    @err = err
    mail to: Se.err_recipients, subject: "[rabotnegi.ru errors] #{@err}"
  end
end
