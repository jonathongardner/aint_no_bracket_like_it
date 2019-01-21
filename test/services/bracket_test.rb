# frozen_string_literal: true

require 'test_helper'
class BracketTest < ActiveSupport::TestCase
  test "should not be finished with bracket without hash representing all games" do
    games = {}
    (1..62).each { |g| games[g.to_s] = {'winner' => 'top'} }
    new_bracket = Bracket.new(games: games)
    assert_not new_bracket.finished?, 'new_bracket should not be finished without all games'
    assert_equal [63], new_bracket.missing_games, 'Should only be missing game 63'
  end
  test "should create finished bracket when all games are passed" do
    games = {}
    (1..63).each { |g| games[g.to_s] = {'winner' => 'top'} }
    new_bracket = Bracket.new(games: games)
    assert new_bracket.finished?, 'new_bracket should be finished with all games'
    assert_equal [], new_bracket.missing_games, 'No games should be missing'
  end
  test "should get hash representing games" do
    games = {
      "1" => {"winner" => "bottom"},
      "3" => {"winner" => "bottom"},
      "5" => {"winner" => "top"},
    }
    new_bracket = Bracket.new(unique_game_number: 47, picked_games: 21)
    assert_equal games, new_bracket.games
  end
  test "should get hash representing games when finished" do
    games = {
      "1" => {"winner" => "bottom"},
      "2" => {"winner" => "bottom"},
      "3" => {"winner" => "bottom"},
      "4" => {"winner" => "bottom"},
      "5" => {"winner" => "top"},
      "6" => {"winner" => "bottom"}
    }
    (7..63).each { |g| games[g.to_s] = {'winner' => 'top'} }
    new_bracket = Bracket.new(unique_game_number: 47, picked_games: Bracket::FINISHED)
    assert_equal games, new_bracket.games
  end
end
