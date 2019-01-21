# frozen_string_literal: true

class UniqueBracketsController < ApplicationController
  before_action :set_unique_bracket, only: [:show]

  # GET /unique_brackets
  def index
    render_bracket current_user.unique_brackets
  end

  # GET /unique_brackets/1
  def show
    render_bracket @unique_bracket
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_unique_bracket
      @unique_bracket = current_user.unique_brackets.find(params[:id])
    end

    def render_bracket(bracket, **options)
      render json: bracket.as_json(only: [:id], methods: :games)
    end
end
