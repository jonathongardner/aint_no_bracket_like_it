# frozen_string_literal: true

module PasswordReset
  extend ActiveSupport::Concern

  included do
    MAX_RESET_PASSWORD_ATTEMPTS = 5
    attr_accessor :reset_token_for_password

    validate :validate_password_reset_token_presence, :validate_password_reset_token

    reject_new_token do
      resetting_password?
    end
  end

  def resetting_password?
    password_reset_token_digest.present? && password_reset_token_attempts.present?
  end

  def reset_password(options)
    assign_attributes(
      reset_token_for_password: options[:reset_token] || '', # Pass so validation is called
      password: options[:new_password],
      password_confirmation: options[:new_password_confirmation],
      password_reset_token_digest: nil,
      password_reset_token_attempts: nil
    )
  end

  def validate_password_reset_token_presence
    return if password_reset_token_digest.present? == password_reset_token_attempts.present?
    p_b = password_reset_token_digest.present? ? ['blank', 'present'] : ['present', 'blank']
    errors.add(:password_reset_token_attempts, "can't be #{p_b[0]} if password_reset_token is #{p_b[1]}")
  end

  def validate_password_reset_token
    return unless self.reset_token_for_password
    return if persisted? && password_reset_token_attempts.to_i < MAX_RESET_PASSWORD_ATTEMPTS && valid_password_reset_token
    errors.add(:password_reset_token, "doesn't match email")
  end

  def valid_password_reset_token
    password_reset_token_digest_changed? && BCrypt::Password.new(password_reset_token_digest_was) == reset_token_for_password
  end

  module ClassMethods
    def forgot_password(email, reset: false)
      # rese should only be used by admins
      user = find_by(email: email)
      return if user.nil?
      return unless reset || user.password_reset_token_digest.blank?

      token = SecureRandom.hex(16)
      user.assign_attributes(
        password_reset_token_digest: BCrypt::Password.create(token),
        password_reset_token_attempts: 0
      )
      # TODO Send email about reset token
      user.save
      user.clear_sessions
      token
    end

    def reset_password!(email, options)
      user = find_by(email: email) || User.new

      user.reset_password(options)
      user.save!
    end

    def failed_password_reset_attempt(email)
      user = find_by(email: email) || User.new
      return user unless user.persisted? && user.password_reset_token_attempts < MAX_RESET_PASSWORD_ATTEMPTS
      user.password_reset_token_attempts += 1
      user.save(validate: false)
      user
    end
  end
end
