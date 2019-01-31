# frozen_string_literal: true

class ApplicationController < ActionController::API
  include HelpfulResponses
  update_expired_session_tokens!
  require_login!

  reject_token do
    !current_user.approved
  end

  catch_invalid_token
  catch_access_denied
  rescue_from ActiveRecord::RecordInvalid, ActiveRecord::RecordNotDestroyed do |e|
    render json: {errors: e.record.errors}, status: :unprocessable_entity
  end
end
