# frozen_string_literal: true

class SavedBracketsController < ApplicationController
  before_action :set_saved_bracket, only: [:show, :update, :destroy]

  # GET /saved_brackets
  def index
    render json: current_user.saved_brackets
  end

  # GET /saved_brackets/1
  def show
    render json: @saved_bracket
  end

  # POST /saved_brackets
  def create
    @saved_bracket = SavedBracket.new(saved_bracket_params.merge(user_id: current_user.id))

    if @saved_bracket.save
      render json: @saved_bracket, status: :created, location: @saved_bracket
    else
      render json: @saved_bracket.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /saved_brackets/1
  def update
    if @saved_bracket.update(saved_bracket_params)
      render json: @saved_bracket
    else
      render json: @saved_bracket.errors, status: :unprocessable_entity
    end
  end

  # DELETE /saved_brackets/1
  def destroy
    @saved_bracket.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_saved_bracket
      @saved_bracket = current_user.saved_brackets.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def saved_bracket_params
      params.require(:saved_bracket).permit(:unique_game_number, :picked_games)
    end
end
