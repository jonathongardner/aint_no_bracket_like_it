# frozen_string_literal: true

class BracketsController < ApplicationController
  def show
    bracket = TournamentMatchUp.includes(top_tournament_team: :team, bottom_tournament_team: :team)
      .where(tournament_teams: {year: params[:year]})


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

    to_return = bracket.reduce({}) do |acc, match_up|
      acc.merge(match_up.game => {
        'top' => {
          'name' => match_up.top_tournament_team.team.name,
          'shortName' => match_up.top_tournament_team.team.short_name,
          'rank' => match_up.top_tournament_team.rank,
          'score' => match_up.top_team_score,
        },
        'bottom' => {
          'name' => match_up.bottom_tournament_team.team.name,
          'shortName' => match_up.bottom_tournament_team.team.short_name,
          'rank' => match_up.bottom_tournament_team.rank,
          'score' => match_up.top_team_score,
        },
        'winner' => match_up.winner,
      })
    end
    render json: to_return, status: :ok
  end

  def initial
    bracket = TournamentMatchUp.includes(top_tournament_team: :team, bottom_tournament_team: :team)
      .where(game: ((-1.0 / 0)..32), tournament_teams: {year: params[:year]})

    to_return = bracket.reduce({}) do |acc, match_up|
      acc.merge(match_up.game => {
        'top' => {
          'name' => match_up.top_tournament_team.team.name,
          'shortName' => match_up.top_tournament_team.team.short_name,
          'rank' => match_up.top_tournament_team.rank,
        },
        'bottom' => {
          'name' => match_up.bottom_tournament_team.team.name,
          'shortName' => match_up.bottom_tournament_team.team.short_name,
          'rank' => match_up.bottom_tournament_team.rank,
        }
      })
    end
    render json: to_return, status: :ok
  end
end