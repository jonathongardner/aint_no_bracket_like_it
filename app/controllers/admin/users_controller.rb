# frozen_string_literal: true
module Admin
  class UsersController < ApplicationController
    require_user_load!
    before_action :set_user, only: [:approve, :email_confirmation, :forgot_password]

    reject_token do
      !current_user.admin
    end

    skip_callback! only: :validate_email

    # GET /admin/users
    def index
      to_return = User.where.not(id: current_user.id) # ignore self
      to_return = to_return.where(approved: params[:approved]) if params.key?(:approved)
      admin_render(to_return)
    end

    # POST /admin/users/:user_id/approve
    def approve
      admin_render @user.update_self!(approved: params.key?(:approved) ? params[:approved] : true)
    end

    # POST /admin/users/:user_id/email_confirmation
    def email_confirmation
    end

    # GET /admin/users/:user_id/forgot_password
    def forgot_password
      reset_password_log("forgot password")

      @user.forgot_password
      # Return success no mater what so cant figure out if email exist or not
      head :ok
    end

    private
      def admin_render(to_return)
        render json: to_return.as_json(only: [:id, :username, :approved])
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_user
        @user = User.find(params[:user_id])
      end

      def reset_password_log(text)
        Rails.logger.info("ADMIN PASSWORD RESET: #{text} for #{params[:login]}.")
      end
  end
end
