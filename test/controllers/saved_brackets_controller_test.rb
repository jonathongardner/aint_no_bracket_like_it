# frozen_string_literal: true

require 'test_helper'
class SavedBracketsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @saved_bracket = saved_brackets(:some_great_users_47_bracket)
  end

  test "should get index for some_great_user but not no user" do
    get saved_brackets_url
    assert_response :unauthorized, 'Should be unauthorized for no user'

    user = users(:some_great_user)
    authorized_get user, saved_brackets_url
    assert parsed_response.all? { |sb| sb['user_id'] == user.id }, 'All saved brackets should be from the current user'
  end

  test "should show saved_bracket for some_great_user but no user or wrong user" do
    sb = saved_brackets(:some_great_users_47_bracket)

    get saved_bracket_url(sb)
    assert_response :unauthorized, 'Should be unauthorized for no user'

    authorized_get users(:another_great_user), saved_bracket_url(sb)
    assert_response :not_found, 'Should be not_found for wrong user'

    authorized_get sb.user, saved_bracket_url(sb)
    assert_response :success
  end

  test "should create saved_bracket for a user but not no user" do
    params = {
      saved_bracket: {
        unique_game_number: 1234567,
        picked_games: 1234567,
        user_id: users(:another_great_user).id
      }
    }
    assert_no_difference('SavedBracket.count') do
      post saved_brackets_url, params: params
      assert_response :unauthorized, 'Should be unauthorized for no user'
    end

    user = users(:some_great_user)
    assert_difference('SavedBracket.count') do
      authorized_post user, saved_brackets_url, params: params
      assert_response :success, 'Should be success for a user'
    end
    assert_equal parsed_response['user_id'], user.id, 'Should be the user who created not the passed user'
  end

  test "should update saved_bracket for a user but not no user or wrong user" do
    sb = saved_brackets(:some_great_users_47_bracket)
    params = {
      saved_bracket: {
        unique_game_number: 1234567,
        user_id: users(:another_great_user).id
      }
    }
    patch saved_bracket_url(sb), params: params
    assert_response :unauthorized, 'Should be unauthorized for no user'

    authorized_patch users(:another_great_user), saved_bracket_url(sb), params: params
    assert_response :not_found, 'Should be not_found for wrong user'

    user = sb.user
    authorized_patch user, saved_bracket_url(sb), params: params
    assert_response :success, 'Should be success for correct user'
    assert_equal parsed_response['user_id'], user.id, 'Should be the user who created not the passed user'
  end

  test "should destroy saved_bracket" do
    sb = saved_brackets(:some_great_users_47_bracket)
    assert_no_difference('SavedBracket.count') do
      delete saved_bracket_url(sb)
      assert_response :unauthorized, 'Should be unauthorized for no user'
    end

    assert_no_difference('SavedBracket.count') do
      authorized_delete users(:another_great_user), saved_bracket_url(sb)
      assert_response :not_found, 'Should be not_found for wrong user'
    end

    user = sb.user
    assert_difference('SavedBracket.count', -1) do
      authorized_delete user, saved_bracket_url(sb)
      assert_response :no_content, 'Should be no_content for correct user'
    end
  end
end
