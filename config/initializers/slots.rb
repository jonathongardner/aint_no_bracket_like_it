Slots.configure do |config|
  config.logins = {email: /@/, username: //}
  # config.login_regex_validations = true
  # config.authentication_model = 'User'
  # config.secret = ENV['SLOT_SECRET']
  # config.token_lifetime = 2.minutes # 1.hour
  # config.session_lifetime = 2.weeks
  # config.secret_yaml = false # Set to nil to not allow sessions
end
