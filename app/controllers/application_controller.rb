# frozen_string_literal: true

class ApplicationController < ActionController::API
  require_login!

  catch_invalid_token

  rescue_from ActiveRecord::RecordNotFound do |_e|
    render json: {errors: {record_not_found: [_e.to_s]}}, status: :not_found
  end
end
