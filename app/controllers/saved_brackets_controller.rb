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
      # This will allow
      # {
      #   "games" => {
      #     "1" => {"winner"=>"top"},
      #     "2" => {"winner"=>"top"}
      #   }
      # }
      params.require(:saved_bracket).permit(:name, :is_unique, games: [:winner])
    end

    def render_bracket(bracket, **options)
      render json: bracket.as_json(only: [:id, :name], methods: :games)
    end
end
