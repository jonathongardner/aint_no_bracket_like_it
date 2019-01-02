# frozen_string_literal: true

class TournamentTeam < ApplicationRecord
  belongs_to :team
  validates :year, :rank, presence: true
  validates :team, uniqueness: {scope: :year}
end
