# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
  def boas_vindas(user_id)
    @user = User.find(user_id)
    @subject = "Bem-vindo(a) ao #{Rails.application.config.site_name}!"

    mail(
      to: @user.email,
      subject: @subject
    )
  end
end
