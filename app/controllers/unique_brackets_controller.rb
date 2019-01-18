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

  # POST /unique_brackets
  def create
    @unique_bracket = UniqueBracket.new(unique_bracket_params.merge(user_id: current_user.id))

    if @unique_bracket.save
      render_bracket @unique_bracket, status: :created, location: @unique_bracket
    else
      render_error @unique_bracket
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_unique_bracket
      @unique_bracket = current_user.unique_brackets.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def unique_bracket_params
      params.require(:unique_bracket).permit(games: [:winner])
    end

    def render_bracket(bracket, **options)
      render json: bracket.as_json(only: [:id], methods: :games)
    end
end
