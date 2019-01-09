# frozen_string_literal: true

class User < ApplicationRecord
  slots :database_authentication, :approvable
end
