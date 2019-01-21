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
end
