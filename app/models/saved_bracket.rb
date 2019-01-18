# frozen_string_literal: true

class SavedBracket < ApplicationRecord
  include BracketBinary
  belongs_to :user
  validates :name, :unique_game_number, :picked_games, presence: true

  def binary_picked_games=(v)
    self.picked_games = v.to_i(2)
  end
end
