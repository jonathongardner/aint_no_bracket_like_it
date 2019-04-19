# frozen_string_literal: true

class UsersController < ApplicationController
  # Need to reload on update so info is correct and do overwrite data
  require_user_load!
  ignore_login! only: [:create, :forgot_password, :reset_password]
  # Ignore token forbidden
  skip_callback! only: :validate_email


  # POST /users
  def create
    @_current_user = User.create!(user_params(:email))
    current_user.create_token(ActiveModel::Type::Boolean.new.cast(params[:session]))
    set_token_header!
    render json: current_user.as_json, status: :created
  end

  # PATCH/PUT /users
  def update
    # To change any user information you need to reenter the password
    current_user.authenticate!(params[:password])
    current_user.update_token
    render json: current_user.update_self!(user_params).as_json, status: :accepted
  end

  # GET users/validate_email
  def validate_email
    current_user.update!(email_confirmation_params.merge(email_confirmed: true, email_confirmation_token_digest: nil))
    current_user.update_token # Should returne updated token
    head :ok
  end

  # GET users/forgot_password
  def forgot_password
    reset_password_log("forgot password")
    user = User.find_by(email: params[:email])
    # Use method rather than validations because should always return true
    user.forgot_password if user && user.reset_password_token_digest.blank?
    # Return success no mater what so cant figure out if email exist or not
    head :ok
  end

  # GET users/reset_password
  def reset_password
    reset_password_log("resetting password")
    # Use method rather than validations because should always return true
    User.reset_password!(params[:email], reset_password_params)
    reset_password_log("successfully reset password")

    head :ok
  rescue ActiveRecord::RecordInvalid => e
    failed_user = User.failed_reset_password_attempt(params[:email])
    reset_password_log("failed reset password attempt (attempts #{failed_user.reset_password_attempts})")
    render json: {errors: e.record.errors.as_json.slice(:password_confirmation, :reset_password_token) }, status: :unprocessable_entity
  end

  # # DELETE /manages/1
  # def destroy
  #   @manage.destroy
  #   redirect_to manages_url, notice: 'Manage was successfully destroyed.'
  # end

  private
    # Only allow a trusted parameter "white list" through.
    def user_params(*extra_params)
      params.require(:user).permit(:username, :password, :password_confirmation, *extra_params)
    end

    def email_confirmation_params
      params.permit(:email_confirmation_token)
    end

    def reset_password_params
      params.permit(:reset_password_token, :new_password, :new_password_confirmation)
    end

    def reset_password_log(text)
      Rails.logger.info("PASSWORD RESET: #{text} for #{params[:login]}.")
    end
end
