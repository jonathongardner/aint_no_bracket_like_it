# frozen_string_literal: true

class UniqueBracket < ApplicationRecord
  include BracketBinary
  belongs_to :user
  # validates :unique_game_number, presence: true, uniqueness: true
  validate :has_all_games

  def unique_game_number
    self.id
  end
  def unique_game_number=(v)
    self.id = v
  end

  def picked_games
    9223372036854775807 # This is 111....111 in binary i.e. all picked
  end

  def has_all_games
    return unless @games
    missing_games = (1..63).to_a - @games.keys.map(&:to_i)
    return unless missing_games.present?
    self.errors.add(:games, "are missing #{missing_games}")
  end
end
