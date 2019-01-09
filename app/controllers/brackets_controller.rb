# frozen_string_literal: true

class BracketsController < ApplicationController
  ignore_login! only: [:show, :initial, :stats]
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
            'score' => match_up.bottom_team_score,
          },
          'winner' => match_up.winner,
        })
      end
    render json: to_return, status: :ok
  end

  def initial
    to_return = TournamentMatchUp.includes(top_tournament_team: :team, bottom_tournament_team: :team)
      .where(game: ((-1.0 / 0)..32), tournament_teams: {year: params[:year]})
      .reduce({}) do |acc, match_up|
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

  def stats
    tmu_count = TournamentMatchUp.arel_table[:id].count
    base_query = TournamentMatchUp.gameIs(params[:game_number])

    top_seeds = base_query.joins(:top_tournament_team)
      .order(count: :desc)
      .group(:rank)
      .select(:rank, tmu_count.as('count'))
      .as_json(except: :id)

    bottom_seeds = base_query.joins(:bottom_tournament_team)
      .order(count: :desc)
      .group(:rank)
      .select(:rank, tmu_count.as('count'))
      .as_json(except: :id)

    top_rank = TournamentTeam.arel_table[:rank]
    bottom_rank = TournamentTeam.arel_table.alias('bottom_tournament_teams_tournament_match_ups')[:rank]
    common_match_ups = base_query.joins(:top_tournament_team, :bottom_tournament_team)
      .order(count: :desc)
      .group(top_rank, bottom_rank)
      .pluck(top_rank.as('top_rank'), bottom_rank.as('bottom_rank'), tmu_count.as('count'))
      .reduce([]) do |acc, mu|
        acc.push(
          'topRank' => mu[0],
          'bottomRank' => mu[1],
          'count' => mu[2]
        )
      end

    match_ups_json = base_query.eager_load(top_tournament_team: :team, bottom_tournament_team: :team)
      .order(TournamentTeam.arel_table[:year])
      .reduce({}) do |acc, match_up|
        acc.merge(match_up.top_tournament_team.year => {
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
            'score' => match_up.bottom_team_score,
          },
          'winner' => match_up.winner,
        })
      end

    to_return = {
      'commonTopRank' => top_seeds,
      'commonBottomRank' => bottom_seeds,
      'commonMatchUps' => common_match_ups,
      'allGames' => match_ups_json,
    }

    render json: to_return, status: :ok
  end

  private
end
