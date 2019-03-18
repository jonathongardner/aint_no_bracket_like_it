# frozen_string_literal: true

require 'test_helper'
class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get users if authanticated and admin" do
    get users_url
    assert_response :unauthorized, 'Should be unauthorized for no user'

    authorized_get users(:some_great_user), users_url
    assert_response :forbidden, 'Should be forbidden for none admin'

    user = users(:some_great_admin_user)

    authorized_get user, users_url
    assert parse_response.all? { |u| u['id'] != user.id }, 'Should not return itself'
    assert parsed_response.any? { |u| u['approved'] }, 'Should return approved'
    assert parsed_response.any? { |u| !u['approved'] }, 'Should return unapproved'

    authorized_get user, users_url(approved: true)
    assert parse_response.all? { |u| u['approved'] }, 'Should only return approved'

    authorized_get user, users_url(approved: false)
    assert parse_response.all? { |u| !u['approved'] }, 'Should only return unapproved'
  end

  test "should approve users if authanticated and admin" do
    to_approve = users(:unapproved_user)

    post user_approve_url(user_id: to_approve)
    assert_response :unauthorized, 'Should be unauthorized for no user'

    authorized_post users(:some_great_user), user_approve_url(user_id: to_approve)
    assert_response :forbidden, 'Should be forbidden for none admin'

    current_user = users(:some_great_admin_user)

    authorized_post current_user, user_approve_url(user_id: to_approve)
    assert parse_response['approved'], 'Should be approved'

    authorized_post current_user, user_approve_url(user_id: to_approve, approved: false)
    assert_not parse_response['approved'], 'Should be unapproved'

    authorized_post current_user, user_approve_url(user_id: to_approve, approved: true)
    assert parse_response['approved'], 'Should be approved'

    authorized_post current_user, user_approve_url(user_id: to_approve) # Make sure not toggling
    assert parse_response['approved'], 'Should be approved'
  end

  test "should create user for a no user" do
    to_create = {
      email: 'email@somewhere.com', username: 'username',
      password: 'Password', password_confirmation: 'Password'
    }
    assert_difference('User.count') do
      post users_url, params: { users: to_create }
      assert_response :success
    end
  end

  test "should update user for current_user" do
    # TODO check that can send without password_confirmation
    to_update = {
      username: 'new_username', password: 'Password', password_confirmation: 'Password'
    }
    patch users_url
    assert_response :unauthorized, 'Should be unauthorized for no user'

    current_user = users(:some_great_user)

    authorized_patch current_user, users_url, params: { users: to_update }
    assert_response :unauthorized, 'Should be unauthorized if no password sent'

    authorized_patch current_user, users_url, params: { password: 'password', users: to_update }
    assert_response :success

    current_user.reload
    assert_not current_user.authenticate?('password'), 'Should not still have password'
    assert current_user.authenticate?('Password'), 'Should have updated password'
  end
end
