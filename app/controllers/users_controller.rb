# frozen_string_literal: true

class UsersController < ApplicationController
  ignore_login! only: [:create, :forgot_password, :reset_password]
  # Need to reload on update so info is correct and do overwrite data
  require_user_load! except: [:create]

  reject_token(only: [:index, :approve, :admin_forgot_password]) do
    !current_user.admin
  end

  # GET /users
  def index
    to_return = User.where.not(id: current_user.id) # ignore self
    to_return = to_return.where(approved: params[:approved]) if params.key?(:approved)
    admin_render(to_return)
  end

  # POST /users/:user_id/approve
  def approve
    admin_render User.update!(params[:user_id], approved: params.key?(:approved) ? params[:approved] : true)
  end

  # POST /users
  def create
    @_current_user = User.create!(user_params(:email))
    current_user.create_token(ActiveModel::Type::Boolean.new.cast(params[:session]))
    set_token_header!
    render json: current_user.as_json, status: :created
  end

  # GET /admin/forgot_password
  def admin_forgot_password
    reset_password_log("forgot password")

    # Use method rather than validations because should always return true
    User.forgot_password(params[:email], reset: true)
    # Return success no mater what so cant figure out if email exist or not
    head :ok
  end

  # GET /forgot_password
  def forgot_password
    reset_password_log("forgot password")

    # Use method rather than validations because should always return true
    User.forgot_password(params[:email])
    # Return success no mater what so cant figure out if email exist or not
    head :ok
  end

  # GET /reset_password
  def reset_password
    reset_password_log("resetting password")
    # Use method rather than validations because should always return true
    User.reset_password!(params[:email], reset_password_params)
    reset_password_log("successfully reset password")

    head :ok
  rescue ActiveRecord::RecordInvalid => e
    failed_user = User.failed_password_reset_attempt(params[:email])
    reset_password_log("failed reset password attempt (attempts #{failed_user.password_reset_token_attempts})")
    render json: {errors: e.record.errors.as_json.slice(:password_confirmation, :password_reset_token) }, status: :unprocessable_entity
  end

  # PATCH/PUT /users
  def update
    # TODO Think about returning the token on create
    # To change any user information you need to reenter the password
    current_user.authenticate!(params[:password])
    render json: current_user.update_self!(user_params).as_json, status: :accepted
  end
  # # DELETE /manages/1
  # def destroy
  #   @manage.destroy
  #   redirect_to manages_url, notice: 'Manage was successfully destroyed.'
  # end

  private
    def admin_render(to_return)
      render json: to_return.as_json(only: [:id, :username, :email, :approved])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params(*extra_params)
      params.require(:user).permit(:username, :password, :password_confirmation, *extra_params)
    end

    def reset_password_params
      params.permit(:reset_token, :new_password, :new_password_confirmation)
    end

    def reset_password_log(text)
      Rails.logger.info("PASSWORD RESET: #{text} for #{params[:login]}.")
    end
end
