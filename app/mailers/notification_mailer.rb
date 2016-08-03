class NotificationMailer < ApplicationMailer

  default from: "changsharma@gmail.com"

  def notification_email(receiver_email)
      mail(to: receiver_email, subject: 'Sample Email')
  end
end