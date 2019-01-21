# frozen_string_literal: true

class UniqueBracket < ApplicationRecord
  belongs_to :user
  has_one :saved_bracket, -> () { where(is_unique: true) }, foreign_key: :unique_game_number

  scope :no_user, -> () { where(user_id: nil) }
  scope :top_bracket_matches, -> (n) { where(Arel::Nodes::BitwiseAnd.new(arel_table_not_id, n).eq(n)) }
  scope :bottom_bracket_matches, -> (n) { where(Arel::Nodes::BitwiseAnd.new(arel_table[:id], n).eq(n)) }

  # convert to binary becasue will read ~ as negative (so probably converting to signed in)
  scope :pluck_top_and_bottom, -> (pg) { pluck(Arel.sql("(bit_or(~id) & ~#{pg})::bit(63)"), Arel.sql("(bit_or(id) & ~#{pg})::bit(63)")).first }
  scope :pluck_binary, -> () { pluck(Arel.sql("(id)::bit(63)")) }
  def bracket
    return @bracket if @bracket
    @bracket = Bracket.new(unique_game_number: self.id, picked_games: Bracket::FINISHED)
  end

  def games
    bracket.games
  end

  private
    def self.arel_table_not_id
      Arel::Nodes::BitwiseNot.new(arel_table[:id])
    end

  # UniqueBracket.where("(unique_brackets.id & 7) = 7").pluck("bit_or(unique_brackets.id)", "bit_or(~unique_brackets.id)")
end
