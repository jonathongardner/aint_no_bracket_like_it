# frozen_string_literal: true

class BracketsController < ApplicationController
  ignore_login! only: [:show, :initial, :stats]

  def show
    match_ups = TournamentMatchUp.include_teams.year_is(params[:year])

    render_tournament_match_up match_ups
  end

  def initial
    # -1.0/0 is -Inf this will do <= 32 in SQL
    match_ups = TournamentMatchUp.include_teams.year_is(params[:year]).game_is(((-1.0 / 0)..32))

    render_tournament_match_up match_ups, except: ['winner', 'score']
  end

  def stats
    base_query = TournamentMatchUp.game_is(params[:game_number])

    top_seeds = base_query.top_rank_counts.as_json(except: :id)
    bottom_seeds = base_query.bottom_rank_counts.as_json(except: :id)

    common_match_ups = base_query.match_up_rank_counts.reduce([]) do |acc, mu|
      acc.push('topRank' => mu.top_rank, 'bottomRank' => mu.bottom_rank, 'count' => mu.count)
    end

    match_ups_json = base_query.include_teams
      .references(:top_tournament_team)
      .order(TournamentTeam.arel_table[:year])
      .reduce({}) { |acc, mu| acc.merge(mu.top_tournament_team.year => tournament_match_up_response(mu)) }

    render json: {
      'commonTopRank' => top_seeds,
      'commonBottomRank' => bottom_seeds,
      'commonMatchUps' => common_match_ups,
      'allGames' => match_ups_json,
    }, status: :ok
  end

  private
end
