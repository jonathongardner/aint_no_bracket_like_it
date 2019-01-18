# frozen_string_literal: true

require 'test_helper'
class SavedBracketTest < ActiveSupport::TestCase
  test "should not create saved_bracket without name, unique_game_number, picked_games, or user" do
    new_saved_bracket = SavedBracket.new
    assert_not new_saved_bracket.save, 'Saved new saved_bracket without name, unique_game_number, picked_games and user'
    assert_error_message "can't be blank", new_saved_bracket, :name, :unique_game_number, :picked_games
    assert_error_message "must exist", new_saved_bracket, :user
    assert_number_of_errors 4, new_saved_bracket
  end
  test "should create saved_bracket" do
    new_saved_bracket = SavedBracket.new(name: 'CoolName', unique_game_number: 5, picked_games: 1, user: users(:some_great_user))
    assert new_saved_bracket.save, 'Did not save new saved_bracket with correct info'
  end
  test "should create saved_bracket with hash representing games" do
    games = {
      "1" => {"winner" => "bottom"},
      "2" => {"winner" => "bottom"},
      "4" => {"winner" => "top"},
      "5" => {"winner" => "top"}
    }
    new_saved_bracket = SavedBracket.new(name: 'CoolName', games: games, user: users(:some_great_user))
    assert new_saved_bracket.save, 'Did not save new saved_bracket with correct info'
    # unique_game_number will not be 35 like some_great_users_35_bracket because
    # 35 to binary is "100011" and 27 is "11011" so the left most 1 wont matter because
    # there is no 1 in the picked games
    assert_equal 3, new_saved_bracket.unique_game_number, 'should set unique_game_number'
    assert_equal 27, new_saved_bracket.picked_games, 'should set picked_games'
  end
  test "should get hash representing games" do
    games = {
      "1" => {"winner" => "bottom"},
      "2" => {"winner" => "bottom"},
      "4" => {"winner" => "top"},
      "5" => {"winner" => "top"}
    }
    assert_equal games, saved_brackets(:some_great_users_35_bracket).games
  end
end
