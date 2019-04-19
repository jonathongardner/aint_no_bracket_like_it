module UserMailerHelper
  BASE_URL='https://localhost:8080/'
  EMAIL_CONFIRMATION_BASE_URL = "#{BASE_URL}/confirm-email/"
  RESET_PASSWORD_BASE_URL = "#{BASE_URL}reset_password/"

  def vue_email_confirmation_url
    "#{EMAIL_CONFIRMATION_BASE_URL}#{@email_confirmation_token}"
  end

  def vue_reset_password_url
    "#{RESET_PASSWORD_BASE_URL}#{@reset_password_token}"
  end
end
