# frozen_string_literal: true

class SavedBracketsController < ApplicationController
  before_action :set_saved_bracket, only: [:show, :update, :destroy]

  # GET /saved_brackets
  def index
    render_bracket current_user.saved_brackets
  end

  # GET /saved_brackets/1
  def show
    render_bracket @saved_bracket
  end

  # POST /saved_brackets
  def create
    render_bracket SavedBracket.create!(saved_bracket_params.merge(user_id: current_user.id)),
      status: :created, location: @saved_bracket
  end

  # PATCH/PUT /saved_brackets/1
  def update
    render_bracket @saved_bracket.update_self!(saved_bracket_params)
  end

  # DELETE /saved_brackets/1
  def destroy
    @saved_bracket.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_saved_bracket
      @saved_bracket = current_user.saved_brackets.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def saved_bracket_params
      # This will allow
      # {
      #   "games" => {
      #     "1" => {"winner"=>"top"},
      #     "2" => {"winner"=>"top"}
      #   }
      # }
      params.require(:saved_bracket).permit(:name, :is_unique, games: [:winner])
    end

    def render_brackets(bracket, **options)
    end

    def render_bracket(bracket, **options)
      if bracket.is_a?(SavedBracket)
        render json: bracket_response(bracket)
      else
        render json: bracket.map { |b| bracket_response(b) }
      end
    end

    def bracket_response(bracket)
      {
        id: bracket.id,
        name: bracket.name,
        games: bracket.games,
        isUnique: bracket.is_unique,
        uniqueBracketNumber: bracket.unique_game_number,
        updatedAt: bracket.updated_at
      }
    end
end
