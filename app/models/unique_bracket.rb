# frozen_string_literal: true

class UniqueBracket < ApplicationRecord
  belongs_to :user
  has_one :saved_bracket, -> () { where(is_unique: true) }, foreign_key: :unique_game_number

  def bracket
    return @bracket if @bracket
    @bracket = Bracket.new(unique_game_number: self.id, picked_games: Bracket::FINISHED)
  end

  def games
    bracket.games
  end
end
