# frozen_string_literal: true

module TournamentResponse
  extend ActiveSupport::Concern

  # bracket_as_json = bracket.as_json(
  #   only: [:game, :top_team_score, :bottom_team_score],
  #   methods: :winner,
  #   include: {
  #     top_tournament_team: {only: :rank, include: {team: {only: [:name, :short_name]}}},
  #     bottom_tournament_team: {only: :rank, include: {team: {only: [:name, :short_name]}}}
  #   }
  # )
  # Return as object rather than array because when games are being played they
  # might not be played in order so game 2 might be done before game 1
  def tournament_match_up_response(match_up, except: [])
    {
      'top' => {
        'name' => match_up.top_tournament_team.team.name,
        'shortName' => match_up.top_tournament_team.team.short_name,
        'rank' => match_up.top_tournament_team.rank,
        'score' => match_up.top_team_score,
      }.except(*except),
      'bottom' => {
        'name' => match_up.bottom_tournament_team.team.name,
        'shortName' => match_up.bottom_tournament_team.team.short_name,
        'rank' => match_up.bottom_tournament_team.rank,
        'score' => match_up.bottom_team_score,
      }.except(*except),
      'winner' => match_up.winner,
    }.except(*except)
  end
end
