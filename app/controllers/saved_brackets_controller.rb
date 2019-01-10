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
    @saved_bracket = SavedBracket.new(saved_bracket_params.merge(user_id: current_user.id))

    if @saved_bracket.save
      render_bracket @saved_bracket, status: :created, location: @saved_bracket
    else
      render_error @saved_bracket
    end
  end

  # PATCH/PUT /saved_brackets/1
  def update
    if @saved_bracket.update(saved_bracket_params)
      render_bracket @saved_bracket
    else
      render_error @saved_bracket
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
      params.require(:saved_bracket).permit(:name, games: [
        :"1", :"2", :"3", :"4", :"5", :"6", :"7", :"8", :"9", :"10",
        :"11", :"12", :"13", :"14", :"15", :"16", :"17", :"18", :"19", :"20",
        :"21", :"22", :"23", :"24", :"25", :"26", :"27", :"28", :"29", :"30",
        :"31", :"32", :"33", :"34", :"35", :"36", :"37", :"38", :"39", :"40",
        :"41", :"42", :"43", :"44", :"45", :"46", :"47", :"48", :"49", :"50",
        :"51", :"52", :"53", :"54", :"55", :"56", :"57", :"58", :"59", :"60",
        :"61", :"62", :"63"
      ])
    end

    def render_bracket(bracket, **options)
      render json: bracket.as_json(only: [:id, :name], methods: :games)
    end
end
