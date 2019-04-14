# frozen_string_literal: true

module ResetPassword
  extend ActiveSupport::Concern

  included do
    MAX_RESET_PASSWORD_ATTEMPTS = 5
    attr_accessor :check_reset_password_token
    attr_reader :reset_password_token

    validate :validate_reset_password_token_presence, :validate_reset_password_token

    token_created_callback do
      remove_reset_password_token if resetting_password?
    end
  end

  def remove_reset_password_token
    update!(
      reset_password_token_digest: nil,
      reset_password_attempts: nil
    )
  end

  def resetting_password?
    reset_password_token_digest.present? && reset_password_attempts.present?
  end

  def reset_password(options)
    assign_attributes(
      reset_password_token: options[:reset_password_token], # Pass so validation is called
      password: options[:new_password],
      password_confirmation: options[:new_password_confirmation],
      reset_password_token_digest: nil,
      reset_password_attempts: nil,
      check_reset_password_token: true
    )
  end

  def reset_password_token=(value)
    @reset_password_token = value || ''
    self.reset_password_token_digest = BCrypt::Password.create(@reset_password_token)
    @reset_password_token
  end

  def validate_reset_password_token_presence
    return if reset_password_token_digest.present? == reset_password_attempts.present?
    p_b = reset_password_token_digest.present? ? ['blank', 'present'] : ['present', 'blank']
    errors.add(:reset_password_attempts, "can't be #{p_b[0]} if password_reset_token is #{p_b[1]}")
  end

  def validate_reset_password_token
    return unless check_reset_password_token
    return if persisted? && reset_password_attempts.to_i < MAX_RESET_PASSWORD_ATTEMPTS && valid_reset_password_token
    errors.add(:reset_password_token, "doesn't match email")
  end

  def valid_reset_password_token
    reset_password_token_digest_changed? && BCrypt::Password.new(reset_password_token_digest_was) == reset_password_token
  end

  def forgot_password
    assign_attributes(
      reset_password_token: SecureRandom.hex(16),
      reset_password_attempts: 0
    )
    # TODO Send email about reset token
    clear_sessions if save
  end

  module ClassMethods
    def reset_password!(email, options)
      user = find_by(email: email) || User.new

      user.reset_password(options)
      user.save!
    end

    def failed_reset_password_attempt(email)
      user = find_by(email: email) || User.new
      return user unless user.persisted? && user.reset_password_attempts < MAX_RESET_PASSWORD_ATTEMPTS
      user.reset_password_attempts += 1
      user.save(validate: false)
      user
    end
  end
end
