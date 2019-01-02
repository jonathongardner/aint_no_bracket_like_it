# frozen_string_literal: true

class TournamentMatchUp < ApplicationRecord
  belongs_to :top_tournament_team, class_name: 'TournamentTeam'
  belongs_to :bottom_tournament_team, class_name: 'TournamentTeam'

  validates :top_team_score, presence: {message: "can't be blank if bottom_team_score exists", if: :bottom_team_score}
  validates :bottom_team_score, presence: {message: "can't be blank if top_team_score exists", if: :top_team_score}
end
