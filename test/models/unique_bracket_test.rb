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
  test "should get unique_game_numbers of numbers that are one binary different" do
    unique_bracket = unique_brackets(:some_great_users_47_unique_bracket)
    similary_games = [
      15, 39, 43, 45, 46, 63, 111, 175, 303, 559, 1071, 2095, 4143, 8239, 16431,
      32815, 65583, 131119, 262191, 524335, 1048623, 2097199, 4194351, 8388655,
      16777263, 33554479, 67108911, 134217775, 268435503, 536870959, 1073741871,
      2147483695, 4294967343, 8589934639, 17179869231, 34359738415, 68719476783,
      137438953519, 274877906991, 549755813935, 1099511627823, 2199023255599,
      4398046511151, 8796093022255, 17592186044463, 35184372088879, 70368744177711,
      140737488355375, 281474976710703, 562949953421359, 1125899906842671,
      2251799813685295, 4503599627370543, 9007199254741039, 18014398509482031,
      36028797018964015, 72057594037927983, 144115188075855919, 288230376151711791,
      576460752303423535, 1152921504606847023, 2305843009213693999, 4611686018427387951
    ]
    assert_equal similary_games, unique_bracket.one_different_binary
    assert_equal 5837209276543664175, unique_bracket.top_seed_to_higher_seed_binary
  end
end
