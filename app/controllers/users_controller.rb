# frozen_string_literal: true

class UsersController < ApplicationController
  ignore_login! only: [:create]
  # Need to reload on update so info is correct and do overwrite data
  require_user_load! except: [:create]

  reject_token(only: [:index, :approve]) do
    !current_user.admin
  end

  # GET /users
  def index
    to_return = User.where.not(id: current_user.id) # ignore self
    to_return = to_return.where(approved: params[:approved]) if params.key?(:approved)
    admin_render(to_return)
  end

  # GET /users/:user_id/approve
  def approve
    admin_render User.update!(params[:user_id], approved: params.key?(:approved) ? params[:approved] : true)
  end

  # POST /users
  def create
    # TODO Think about returning the token on create
    # @manage.create_token(ActiveModel::Type::Boolean.new.cast(params[:session]))
    # render json: @manage.as_json(methods: :token), status: :created
    render json: User.create!(user_params).as_json, status: :created
  end

  # PATCH/PUT /users
  def update
    # To change any user information you need to reenter the password
    current_user.authenticate!(params[:password])
    if current_user.update(user_params)
      render json: current_user.as_json, status: :accepted
    else
      render json: {errors: current_user.errors}, status: :unprocessable_entity
    end
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
    def user_params
      params.require(:users).permit(:email, :username, :password, :password_confirmation)
    end
end
