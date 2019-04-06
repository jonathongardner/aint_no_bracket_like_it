# frozen_string_literal: true

class User < ApplicationRecord
  slots :database_authentication
  include PasswordReset

  has_many :saved_brackets
  has_many :unique_brackets

  validates :password_confirmation, presence: true, if: :changing_password?

  def changing_password?
    self.password.present?
  end
end
