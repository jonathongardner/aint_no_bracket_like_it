# frozen_string_literal: true

class TournamentMatchUp < ApplicationRecord
  belongs_to :top_tournament_team, class_name: 'TournamentTeam'
  belongs_to :bottom_tournament_team, class_name: 'TournamentTeam'

  validates :top_team_score, presence: {message: "can't be blank if bottom_team_score exists", if: :bottom_team_score}
  validates :bottom_team_score, presence: {message: "can't be blank if top_team_score exists", if: :top_team_score}

  scope :game_is, -> (gameNumber) { where(game: gameNumber) }
  scope :year_is, -> (year) { where(tournament_teams: {year: year}) }
  scope :include_teams, -> () { includes(top_tournament_team: :team, bottom_tournament_team: :team) }

  def winner
    return nil if self.top_team_score.nil? # && self.bottom_team_score.nil?
    (self.top_team_score > self.bottom_team_score ? 'top' : 'bottom')
  end

  def self.match_up_rank_counts
    top_rank = TournamentTeam.arel_table[:rank]
    bottom_rank = TournamentTeam.arel_table.alias('bottom_tournament_teams_tournament_match_ups')[:rank]

    self.joins(:top_tournament_team, :bottom_tournament_team)
      .order(count: :desc)
      .group(top_rank, bottom_rank)
      .select(top_rank.as('top_rank'), bottom_rank.as('bottom_rank'), arel_table[:id].count.as('count'))
  end

  def self.top_rank_counts
    self.joins(:top_tournament_team).rank_counts
  end

  def self.bottom_rank_counts
    self.joins(:bottom_tournament_team).rank_counts
  end

  private
    def self.rank_counts
      self.order(count: :desc)
        .group(:rank)
        .select(:rank, arel_table[:id].count.as('count'))
    end
end
