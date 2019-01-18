# frozen_string_literal: true

require 'test_helper'
class UniqueBracketsControllerTest < ActionDispatch::IntegrationTest
  test "should get index for some_great_user but not no user" do
    get unique_brackets_url
    assert_response :unauthorized, 'Should be unauthorized for no user'

    user = users(:some_great_user)
    authorized_get user, unique_brackets_url
    ids = parsed_response.map { |sb| sb['id'] }
    assert_equal parsed_response.count, UniqueBracket.where(id: ids, user: user).count, 'All unique brackets should be from the current user'
  end

  test "should show unique_bracket for some_great_user but no user or wrong user" do
    ub = unique_brackets(:some_great_users_47_unique_bracket)

    get unique_bracket_url(ub)
    assert_response :unauthorized, 'Should be unauthorized for no user'

    authorized_get users(:another_great_user), unique_bracket_url(ub)
    assert_response :not_found, 'Should be not_found for wrong user'

    authorized_get ub.user, unique_bracket_url(ub)
    assert_response :success
  end

  test "should create unique_bracket for a user but not no user" do
    games = {}
    (1..63).each { |g| games[g.to_s] = {'winner' => 'top'} }
    params = {
      unique_bracket: {
        games: games,
        user_id: users(:another_great_user).id
      }
    }
    assert_no_difference('UniqueBracket.count') do
      post unique_brackets_url, params: params
      assert_response :unauthorized, 'Should be unauthorized for no user'
    end

    user = users(:some_great_user)
    assert_difference('UniqueBracket.count') do
      authorized_post user, unique_brackets_url, params: params
      assert_response :success, 'Should be success for a user'
    end
    assert_equal user.id, UniqueBracket.find(parsed_response['id']).user_id, 'Should be the user who created not the passed user'
    assert_equal games, parsed_response['games'], 'Should be the games passed' # check strong params are correct

    # params[:unique_bracket][:games] = nil
    # assert_no_difference('UniqueBracket.count') do
    #   authorized_post user, unique_brackets_url, params: params
    #   assert_response :unprocessable_entity, 'Should be unprocessable_entity for a error'
    # end
    # assert_response_error "can't be blank", 'unique_game_number'
  end
end
