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
  test "should not set as unique if bracket is not finished" do
    new_saved_bracket = SavedBracket.new(
      name: 'CoolName', unique_game_number: 5, picked_games: 1, is_unique: true, user: users(:some_great_user)
    )
    assert_not new_saved_bracket.save, 'Saved new saved_bracket as unique when not finished'
    assert_error_message "must have a pick for all games", new_saved_bracket, :base
    assert_number_of_errors 1, new_saved_bracket
  end
  test "should create saved_bracket" do
    lowest = SavedBracket.new(name: 'perfect', unique_game_number: 0, picked_games: 1, user: users(:some_great_user))
    assert lowest.save, 'Did not save new saved_bracket with correct info and prefect bracket'
    assert_equal 0, lowest.unique_game_number, 'Should have same lower number'

    highest = SavedBracket.new(name: 'Chaos', unique_game_number: Bracket::FINISHED, picked_games: Bracket::FINISHED, user: users(:some_great_user))
    assert highest.save, 'Did not save new saved_bracket with correct info and chaos bracket'
    assert_equal Bracket::FINISHED, highest.unique_game_number, 'Should have same high number'
  end
  test "should update name of is_unique" do
    saved_bracket = saved_brackets(:some_great_users_47_bracket)
    saved_bracket.name = 'SomethingElse'
    assert saved_bracket.save, 'Did not update name of saved_bracket when its a is_unique'
  end
  test "should not update unique_game_number, picked_games, or user of is_unique" do
    saved_bracket = saved_brackets(:some_great_users_47_bracket)
    saved_bracket.unique_game_number = 0
    saved_bracket.picked_games = 0
    saved_bracket.is_unique = false
    saved_bracket.user = users(:another_great_user)

    assert_not saved_bracket.save, 'Updated saved_bracket when its a is_unique'
    assert_error_message "can't change after submitting as unique bracket", saved_bracket, :unique_game_number, :picked_games, :is_unique, :user
    assert_number_of_errors 4, saved_bracket
  end
  test "should not set as unique if bracket is already taken" do
    saved_bracket = saved_brackets(:another_great_users_47_bracket)
    saved_bracket.is_unique = true
    assert_not saved_bracket.save, 'Saved new saved_bracket as unique already taken'
    assert_error_message "bracket has already been taken", saved_bracket, :base
    assert_number_of_errors 1, saved_bracket
  end
  test "should update unique_bracket if set to is_unique" do
    saved_bracket = saved_brackets(:another_great_users_35_bracket)
    assert saved_bracket.update(is_unique: true, picked_games: Bracket::FINISHED), 'Did not save unqiue bracket as unique'

    assert_equal saved_bracket.user, saved_bracket.unique_bracket.user, 'Should set user when set to unique'
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
  test "should not destroy unique bracket" do
    saved_bracket = saved_brackets(:some_great_users_47_bracket)
    assert_not saved_bracket.destroy, 'Destroyed unique bracket'
    assert_error_message "can't be deleted", saved_bracket, :unique
    assert_number_of_errors 1, saved_bracket
  end
  test "should not destroy none unique bracket" do
    saved_bracket = saved_brackets(:another_great_users_47_bracket)
    assert_difference('SavedBracket.count', -1) do
      saved_bracket.destroy!
    end
  end
end
