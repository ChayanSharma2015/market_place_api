class NotificationMailer < ApplicationMailer

  default from: "changsharma@gmail.com"

  def notification_email(receiver_email,article)
    @article = article
    @recipient = receiver_email
    mail(to: receiver_email, subject: 'Article filed for petition')
  end

  def otp_email(receiver_email,otp)
    @recipient = receiver_email
    @otp = otp
    mail(to: receiver_email, subject: 'Your one time password for Market Place App')
  end
end