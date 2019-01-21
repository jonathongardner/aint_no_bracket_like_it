# frozen_string_literal: true

require 'test_helper'
class UniqueBracketTest < ActiveSupport::TestCase
  test "should not update unique_bracket without user" do
    unique_bracket = unique_brackets(:no_one_35_unique_bracket)
    assert_not unique_bracket.save, 'Saved new unique_bracket without unique_game_number and user'
    assert_error_message "must exist", unique_bracket, :user
    assert_number_of_errors 1, unique_bracket
  end

  test "should only link to saved_bracket if is_unique" do
    assert_equal saved_brackets(:some_great_users_47_bracket), unique_brackets(:some_great_users_47_unique_bracket).saved_bracket
    assert_nil unique_brackets(:no_one_35_unique_bracket).saved_bracket
  end

  test "should save highest and lowest bracket" do
    # lowest = UniqueBracket.new(id: 0, user: users(:some_great_user))
    # assert lowest.save, 'Should create lowest bracket'
    # assert_equal 0, lowest.id, 'Should have same number'

    highest = UniqueBracket.new(id: Bracket::FINISHED, user: users(:some_great_user))
    assert highest.save, 'Should create highest bracket'
    assert_equal Bracket::FINISHED, highest.id, 'Should have same number'
  end
end
