# frozen_string_literal: true

class User < ApplicationRecord
  slots :database_authentication
  has_many :saved_brackets
  has_many :unique_brackets

  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP, message: "incorrect format"}
end
