# frozen_string_literal: true

class User < ApplicationRecord
  slots :database_authentication
  has_many :saved_brackets
  has_many :unique_brackets

  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP, message: "incorrect format"}
  validates :password_confirmation, presence: true, if: :changing_password?

  def changing_password?
    self.password.present?
  end
end
