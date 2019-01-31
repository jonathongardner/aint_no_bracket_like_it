# frozen_string_literal: true

class SavedBracket < ApplicationRecord
  belongs_to :user
  belongs_to :unique_bracket, foreign_key: :unique_game_number, optional: true
  validates :name, :unique_game_number, :picked_games, presence: true
  validate :validate_is_unique_is_finished, :validate_and_set_user_for_unique_bracket, :validate_dont_change_is_unique
  before_destroy :check_if_unique


  def check_if_unique
    return unless self.is_unique
    errors.add :unique, "can't be deleted"
    throw(:abort)
  end

  def games=(g)
    @bracket = Bracket.new(games: g)
    self.unique_game_number = @bracket.unique_game_number
    self.picked_games = @bracket.picked_games
  end

  def bracket
    return @bracket if @bracket
    @bracket = Bracket.new(unique_game_number: self.unique_game_number, picked_games: self.picked_games)
  end

  def games
    bracket.games
  end

  private
    def validate_is_unique_is_finished
      return unless self.is_unique
      self.errors.add(:base, "must have a pick for all games") unless bracket.finished?
    end
    def validate_and_set_user_for_unique_bracket
      return unless self.is_unique && self.is_unique_changed?
      # only do if is_unique is set to true i.e. for the first time so if name is updated it doesnt check
      if self.unique_bracket.user_id.nil?
        self.unique_bracket.user = self.user
      else
        self.errors.add(:base, "bracket has already been taken")
      end
    end
    def validate_dont_change_is_unique
      return unless self.is_unique_was
      self.errors.add(:is_unique, "can't change after submitting as unique bracket") if self.is_unique_changed?
      self.errors.add(:unique_game_number, "can't change after submitting as unique bracket") if self.unique_game_number_changed?
      self.errors.add(:picked_games, "can't change after submitting as unique bracket") if self.picked_games_changed?
      self.errors.add(:user, "can't change after submitting as unique bracket") if self.user_id_changed?
    end
end
