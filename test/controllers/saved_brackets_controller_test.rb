# frozen_string_literal: true

require 'test_helper'
class SavedBracketsControllerTest < ActionDispatch::IntegrationTest
  test "should get index for saved_brackets_url" do
    user = users(:some_great_user)
    authorized_get user, saved_brackets_url
    assert_response :success

    ids = parsed_response.map { |sb| sb['id'] }
    assert_equal parsed_response.count, SavedBracket.where(id: ids, user: user).count, 'All saved brackets should be from the current user'
  end

  test "should show saved_bracket for some_great_user" do
    saved_bracket = saved_brackets(:some_great_users_47_bracket)
    authorized_get saved_bracket.user, saved_bracket_url(saved_bracket)
    assert_response :success
  end

  test "should create saved_bracket" do
    games = { "1" => {"winner" => "bottom"} }
    params = {
      saved_bracket: {
        name: 'SomeName',
        games: games,
        user_id: users(:another_great_user).id
      }
    }

    user = users(:some_great_user)
    assert_difference('SavedBracket.count') do
      authorized_post user, saved_brackets_url, params: params
      assert_response :success, 'Should be success for a user'
    end
    assert_equal user.id, SavedBracket.find(parsed_response['id']).user_id, 'Should be the user who created not the passed user'
    assert_equal games, parsed_response['games'], 'Should be the games passed' # check strong params are correct
  end

  test "should not create saved_bracket if error" do
    assert_no_difference('SavedBracket.count') do
      authorized_post users(:some_great_user), saved_brackets_url, params: { saved_bracket: { something: 'test' } }
      assert_response :unprocessable_entity, 'Should be unprocessable_entity for a error'
    end
    assert_response_error "can't be blank", 'name'
  end

  test "should update saved_bracket" do
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

    authorized_patch sb.user, saved_bracket_url(sb), params: params
    assert_response :success, 'Should be success for correct user'
    assert_equal sb.user_id, SavedBracket.find(parsed_response['id']).user_id, 'Should be the user who created not the passed user'
  end

  test "should not update saved_bracket if error" do
    sb = saved_brackets(:some_great_users_35_bracket)

    authorized_patch sb.user, saved_bracket_url(sb), params: {saved_bracket: {name: nil}}
    assert_response :unprocessable_entity, 'Should be unprocessable_entity for a error'
    assert_response_error "can't be blank", 'name'
  end

  test "should destroy saved_bracket" do
    sb = saved_brackets(:some_great_users_35_bracket)

    assert_difference('SavedBracket.count', -1) do
      authorized_delete sb.user, saved_bracket_url(sb)
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

  #----------------------Authentication--------------------------
  test "should have correct authentication for saved_bracket_url index" do
    assert_authentication_response(:great_user_and_above) do |current_user|
      authorized_get current_user, saved_brackets_url
    end
  end

  test "should have correct authentication for saved_bracket_url show" do
    saved_bracket = saved_brackets(:some_great_users_35_bracket)
    assert_authentication_response(:great_user_resource) do |current_user|
      authorized_get current_user, saved_bracket_url(saved_bracket)
    end
  end

  test "should have correct authentication for saved_brackets_url create" do
    params = {
      saved_bracket: {
        name: 'SomeName',
        games: { "1" => {"winner" => "bottom"} },
        user_id: users(:another_great_user).id
      }
    }
    assert_authentication_response(:great_user_and_above) do |current_user|
      authorized_post current_user, saved_brackets_url, params: params
    end
  end

  test "should have correct authentication for saved_bracket_url update" do
    saved_bracket = saved_brackets(:some_great_users_35_bracket)
    params = { saved_bracket: { user_id: fixture_id(:another_great_user) } }
    assert_authentication_response(:great_user_resource) do |current_user|
      authorized_patch current_user, saved_bracket_url(saved_bracket), params: params
    end
  end
end
