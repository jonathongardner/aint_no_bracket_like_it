# frozen_string_literal: true

class ApplicationController < ActionController::API
  require_login!

  catch_invalid_token
end
