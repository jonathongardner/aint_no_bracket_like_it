# frozen_string_literal: true

module EmailConfirmation
  extend ActiveSupport::Concern

  included do
    attr_reader :email_confirmation_token
    validate :validate_email_confirmation

    after_validation :set_email_confirmation, if: :email_changed?
  end

  def email_validated?
    email_confirmation_token_digest.nil?
  end

  def set_email_confirmation
    self.email_confirmation_token_digest = BCrypt::Password.create(SecureRandom.hex(16))
  end

  def email_confirmation_token=(value)
    @email_confirmation_token = value || ''
  end

  def validate_email_confirmation
    return if email_confirmation_token.nil? || BCrypt::Password.new(email_confirmation_token_digest_was) == email_confirmation_token
    errors.add(:email_confirmation_token, "doesn't match")
  end

  module ClassMethods
  end
end
