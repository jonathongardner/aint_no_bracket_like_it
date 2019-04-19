class UserMailer < ApplicationMailer
  helper UserMailerHelper

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.email_confirmation.subject
  #
  def email_confirmation(user, email_confirmation_token)
    @email_confirmation_token = email_confirmation_token
    mail to: user.email, subject: "#{APP_NAME} Email Confirmation"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def reset_password(user, reset_password_token)
    @reset_password_token = reset_password_token
    mail to: user.email, subject: "#{APP_NAME} Reset Password"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_changed.subject
  #
  def password_changed(user)
    @user = user
    mail to: user.email, subject: "#{APP_NAME} Password Changed"
  end
end
