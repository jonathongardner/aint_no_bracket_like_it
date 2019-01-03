# frozen_string_literal: true

class BracketsController < ApplicationController
  def show
    bracket = TournamentMatchUp.includes(top_tournament_team: :team, bottom_tournament_team: :team)
      .where(tournament_teams: {year: params[:year]})


    bracket_as_json = bracket.as_json(
      only: [:game, :top_team_score, :bottom_team_score],
      methods: :winner,
      include: {
        top_tournament_team: {only: :rank, include: {team: {only: :name}}},
        bottom_tournament_team: {only: :rank, include: {team: {only: :name}}}
      }
    )
    # Return as object rather than array because when games are being played they
    # might not be played in order so game 2 might be done before game 1
    to_return = bracket_as_json.reduce({}) do |acc, match_up|
      acc[match_up['game']] = match_up.except('game')
      acc
    end
    render json: to_return, status: :ok
  end
end
