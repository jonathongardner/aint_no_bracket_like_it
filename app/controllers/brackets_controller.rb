# frozen_string_literal: true

class BracketsController < ApplicationController
  ignore_login! only: [:show, :initial, :stats]

  def show
    match_ups = TournamentMatchUp.include_teams.year_is(params[:year])

    raise ActiveRecord::RecordNotFound unless match_ups.present?

    render_tournament_match_up match_ups
  end

  def initial
    # -Inf this will do <= 32 in SQL
    match_ups = TournamentMatchUp.include_teams.year_is(params[:year]).game_is((NEGATIVE_INFINITY..32))

    raise ActiveRecord::RecordNotFound unless match_ups.present?

    render_tournament_match_up match_ups, except: ['winner', 'score']
  end

  def stats
    raise ActiveRecord::RecordNotFound unless params[:game_number].to_i.between?(0, 63)

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
