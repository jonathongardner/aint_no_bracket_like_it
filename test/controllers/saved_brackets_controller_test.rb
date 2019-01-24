# frozen_string_literal: true

require 'test_helper'
class SavedBracketsControllerTest < ActionDispatch::IntegrationTest
  test "should get index for some_great_user but not no user" do
    get saved_brackets_url
    assert_response :unauthorized, 'Should be unauthorized for no user'

    user = users(:some_great_user)
    authorized_get user, saved_brackets_url
    ids = parsed_response.map { |sb| sb['id'] }
    assert_equal parsed_response.count, SavedBracket.where(id: ids, user: user).count, 'All saved brackets should be from the current user'
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
    games = {
      "1" => {"winner" => "bottom"},
      "2" => {"winner" => "bottom"},
      "4" => {"winner" => "top"},
      "5" => {"winner" => "top"}
    }
    params = {
      saved_bracket: {
        name: 'SomeName',
        games: games,
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
    assert_equal user.id, SavedBracket.find(parsed_response['id']).user_id, 'Should be the user who created not the passed user'
    assert_equal games, parsed_response['games'], 'Should be the games passed' # check strong params are correct

    params[:saved_bracket][:name] = nil
    assert_no_difference('SavedBracket.count') do
      authorized_post user, saved_brackets_url, params: params
      assert_response :unprocessable_entity, 'Should be unprocessable_entity for a error'
    end
    assert_response_error "can't be blank", 'name'
  end

  test "should update saved_bracket for a user but not no user or wrong user" do
    sb = saved_brackets(:some_great_users_35_bracket)
    params = {
      saved_bracket: {
        games: {
          "1" => {"winner" => "bottom"},
          "2" => {"winner" => "bottom"},
          "4" => {"winner" => "top"},
          "5" => {"winner" => "top"}
        },
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
    assert_equal user.id, SavedBracket.find(parsed_response['id']).user_id, 'Should be the user who created not the passed user'

    authorized_patch user, saved_bracket_url(sb), params: {saved_bracket: {name: nil}}
    assert_response :unprocessable_entity, 'Should be unprocessable_entity for a error'
    assert_response_error "can't be blank", 'name'
  end

  test "should destroy saved_bracket" do
    sb = saved_brackets(:some_great_users_35_bracket)
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

  test "should not destroy unique saved_bracket" do
    sb = saved_brackets(:some_great_users_47_bracket)
    user = sb.user
    assert_no_difference('SavedBracket.count') do
      authorized_delete user, saved_bracket_url(sb)
      assert_response :unprocessable_entity, 'Should be unprocessable_entity for a error'
    end
    assert_response_error "can't be deleted", 'unique'
  end
end
