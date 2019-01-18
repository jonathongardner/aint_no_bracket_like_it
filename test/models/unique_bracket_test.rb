# frozen_string_literal: true

require 'test_helper'
class UniqueBracketTest < ActiveSupport::TestCase
  test "should not create unique_bracket without unique_game_number, or user" do
    new_unique_bracket = UniqueBracket.new
    assert_not new_unique_bracket.save, 'Saved new unique_bracket without unique_game_number and user'
    assert_error_message "must exist", new_unique_bracket, :user
    assert_number_of_errors 1, new_unique_bracket
  end
  # test "should not create unique_bracket without unique number" do
  #   new_unique_bracket = UniqueBracket.new(
  #     unique_game_number: unique_brackets(:some_great_users_47_unique_bracket).unique_game_number,
  #     user: users(:some_great_user)
  #   )
  #   assert_not new_unique_bracket.save, 'Saved new unique_bracket without unique_game_number being unique'
  #   assert_error_message "has already been taken", new_unique_bracket, :unique_game_number
  #   assert_number_of_errors 1, new_unique_bracket
  # end
  test "should create unique_bracket" do
    new_unique_bracket = UniqueBracket.new(unique_game_number: 5, user: users(:some_great_user))
    assert new_unique_bracket.save, 'Did not save new unique_bracket with correct info'
  end
  test "should not create unique_bracket without hash representing all games" do
    games = {}
    (1..62).each { |g| games[g.to_s] = {'winner' => 'top'} }
    new_unique_bracket = UniqueBracket.new(games: games, user: users(:some_great_user))
    assert_not new_unique_bracket.save, 'Saved unique_bracket without games'
    assert_error_message "are missing [63]", new_unique_bracket, :games
    assert_number_of_errors 1, new_unique_bracket
  end
  test "should create unique_bracket without hash representing games" do
    games = {}
    (1..63).each { |g| games[g.to_s] = {'winner' => 'top'} }
    new_unique_bracket = UniqueBracket.new(games: games, user: users(:some_great_user))
    assert new_unique_bracket.save, 'Did not save new unique_bracket with correct info'
    assert_equal 0, new_unique_bracket.unique_game_number, 'should set unique_game_number'
  end
  test "should get hash representing games" do
    games = {
      "1" => {"winner" => "bottom"},
      "2" => {"winner" => "bottom"},
      "3" => {"winner" => "bottom"},
      "4" => {"winner" => "bottom"},
      "5" => {"winner" => "top"},
      "6" => {"winner" => "bottom"}
    }
    (7..63).each { |g| games[g.to_s] = {'winner' => 'top'} }
    assert_equal games, unique_brackets(:some_great_users_47_unique_bracket).games
  end
end
