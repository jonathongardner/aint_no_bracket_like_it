# frozen_string_literal: true

class User < ApplicationRecord
  slots :database_authentication
  include ResetPassword, EmailConfirmation

  has_many :saved_brackets
  has_many :unique_brackets

  validates :password_confirmation, presence: true, if: :changing_password?

  after_save :clear_sessions, if: :changing_password?
  after_update :send_password_changed_email, if: :changing_password?

  def as_json(*)
    super.except('password_reset_token_digest', 'password_reset_token_attempts', 'email_confirmation_token_digest')
  end

  def changing_password?
    self.password.present?
  end

  def clear_sessions
    self.sessions.delete_all
  end

  def send_password_changed_email
    UserMailer.password_changed(self).deliver_now
  end
end
