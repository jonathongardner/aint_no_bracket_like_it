# frozen_string_literal: true

require 'test_helper'
class TournamentTeamTest < ActiveSupport::TestCase
  test "should not create tournamet team without team, year, or rank" do
    new_tournamet_team = TournamentTeam.new
    assert_not new_tournamet_team.save, 'Saved new tournamet team without team, year and rank'
    assert_error_message "must exist", new_tournamet_team, :team
    assert_error_message "can't be blank", new_tournamet_team, :year, :rank
    assert_number_of_errors 3, new_tournamet_team
  end
  test "should not create tournamet team without unique team in a year" do
    new_tournamet_team = tournament_teams(:duke_blue_devils_tournament_team).dup
    assert_not new_tournamet_team.save, 'Saved new tournamet team without unique team in year'
    assert_error_message "has already been taken", new_tournamet_team, :team
    assert_number_of_errors 1, new_tournamet_team

    new_tournamet_team.year = new_tournamet_team.year + 1
    assert new_tournamet_team.save, 'Did not save new tournamet team with new year'
  end
  test "should create tournamet team" do
    new_team = TournamentTeam.new(team: teams(:duke_blue_devils_team), year: 2018, rank: 2)
    assert new_team.save, 'Did not save new tournamet team with correct info'
  end
end
