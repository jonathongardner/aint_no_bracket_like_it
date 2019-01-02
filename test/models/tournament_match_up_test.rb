require 'test_helper'

class TournamentMatchUpTest < ActiveSupport::TestCase
  test "should not create tournament_match_up without top_tournament_team, or bottom_tournament_team" do
    new_tournament_match_up = TournamentMatchUp.new
    assert_not new_tournament_match_up.save, 'Saved new tournament_match_up without top_tournament_team, or bottom_tournament_team'
    assert_error_message "must exist", new_tournament_match_up, :top_tournament_team, :bottom_tournament_team
    assert_number_of_errors 2, new_tournament_match_up
  end
  # test "should not create tournament_match_up without top_tournament_team, or bottom_tournament_team" do
  #   new_tournament_match_up = tournament_match_ups(:the_real_usc_vs_baylor).dup
  #   assert_not new_tournament_match_up.save, 'Saved new tournament_match_up without unique top_tournament_team and bottom_tournament_team'
  #   assert_error_message "has already been taken", new_tournament_match_up, :top_tournament_team
  #   assert_number_of_errors 1, new_tournament_match_up
  #
  #   new_tournament_match_up.bottom_tournament_team = tournament_teams(:duke_tournament_team)
  #   assert tournament_match_up.save, 'Did not save tournament_match_up with differnt match up'
  # end
  test "should not create tournament_match_up without unique name" do
    tournament_match_up = tournament_match_ups(:the_real_usc_vs_baylor)

    tournament_match_up.top_team_score = 50
    assert_not tournament_match_up.save, 'Saved new tournament_match_up without bottom_team_score when top_team_score is present'
    assert_error_message "can't be blank if top_team_score exists", tournament_match_up, :bottom_team_score
    assert_number_of_errors 1, tournament_match_up

    tournament_match_up.bottom_team_score = 70
    assert tournament_match_up.save, 'Did not save tournament_match_up with top and bottom score'

    tournament_match_up.top_team_score = nil
    assert_not tournament_match_up.save, 'Saved new tournament_match_up without top_team_score when bottom_team_score is present'
    assert_error_message "can't be blank if bottom_team_score exists", tournament_match_up, :top_team_score
    assert_number_of_errors 1, tournament_match_up
  end
  test "should create tournament_match_up" do
    new_tournament_match_up = TournamentMatchUp.new(top_tournament_team: tournament_teams(:baylor_tournament_team), bottom_tournament_team: tournament_teams(:duke_tournament_team))
    assert new_tournament_match_up.save, 'Did not save new tournament_match_up with correct dream info'
  end
end
