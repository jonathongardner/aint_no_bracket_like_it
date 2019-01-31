# frozen_string_literal: true

class AdminController < ApplicationController
  require_user_load!

  reject_token do
    !current_user.admin
  end

  def users
    to_return = User.where.not(id: current_user.id) # ignore self
    to_return = to_return.where(approved: params[:approved]) if params.key?(:approved)
    admin_render(to_return)
  end

  def approve
    admin_render User.update!(params[:id], approved: params.key?(:approved) ? params[:approved] : true)
  end

  private
    def admin_render(to_return)
      render json: to_return.as_json(only: [:id, :username, :email, :approved])
    end
end
