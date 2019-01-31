# frozen_string_literal: true

require 'test_helper'
class AdminControllerTest < ActionDispatch::IntegrationTest
  test "should get users if authanticated and admin" do
    get saved_brackets_url
    assert_response :unauthorized, 'Should be unauthorized for no user'

    authorized_get users(:some_great_user), admin_users_url
    assert_response :forbidden, 'Should be forbidden for none admin'

    user = users(:some_great_admin_user)

    authorized_get user, admin_users_url
    assert parse_response.all? { |u| u['id'] != user.id }, 'Should not return itself'
    assert parsed_response.any? { |u| u['approved'] }, 'Should return approved'
    assert parsed_response.any? { |u| !u['approved'] }, 'Should return unapproved'

    authorized_get user, admin_users_url(approved: true)
    assert parse_response.all? { |u| u['approved'] }, 'Should only return approved'

    authorized_get user, admin_users_url(approved: false)
    assert parse_response.all? { |u| !u['approved'] }, 'Should only return unapproved'
  end

  test "should approve users if authanticated and admin" do
    get saved_brackets_url
    assert_response :unauthorized, 'Should be unauthorized for no user'

    authorized_get users(:some_great_user), admin_users_url
    assert_response :forbidden, 'Should be forbidden for none admin'

    current_user = users(:some_great_admin_user)
    to_approve = users(:unapproved_user)

    authorized_get current_user, admin_approve_url(to_approve)
    assert parse_response['approved'], 'Should be approved'

    authorized_get current_user, admin_approve_url(to_approve, approved: false)
    assert_not parse_response['approved'], 'Should be unapproved'

    authorized_get current_user, admin_approve_url(to_approve, approved: true)
    assert parse_response['approved'], 'Should be approved'

    authorized_get current_user, admin_approve_url(to_approve) # Make sure not toggling
    assert parse_response['approved'], 'Should be approved'
  end
end
