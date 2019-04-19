# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/email_confirmation
  def email_confirmation
    UserMailer.email_confirmation(user, 'token')
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_reset
  def reset_password
    UserMailer.reset_password(user, 'token')
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_changed
  def password_changed
    UserMailer.password_changed(user)
  end


  def user
    @user ||= params[:id] ? User.find(params[:id]) : User.first
  end
end
