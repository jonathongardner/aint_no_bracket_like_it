# frozen_string_literal: true

class ApplicationController < ActionController::API
  include HelpfulResponses
  require_login!

  catch_invalid_token
end
