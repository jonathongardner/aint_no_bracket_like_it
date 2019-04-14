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
      post users_url, params: { user: to_create }
      assert_response :success
    end

    assert_no_difference('User.count') do
      post users_url, params: { user: to_create }
      assert_response :unprocessable_entity, 'Should be unprocessable_entity for a error'
    end
    assert_response_error "has already been taken", 'username'
  end

  test "should update user for current_user" do
    to_update = {
      email: 'new_email', username: 'new_username', password: 'Password', password_confirmation: 'Password'
    }
    patch users_url
    assert_response :unauthorized, 'Should be unauthorized for no user'

    current_user = users(:some_great_user)

    authorized_patch current_user, users_url, params: { user: to_update }
    assert_response :unauthorized, 'Should be unauthorized if no password sent'

    authorized_patch current_user, users_url, params: { password: 'password', user: to_update }
    assert_response :success

    current_user.reload
    refute_equal to_update[:email], current_user.email, 'Should not update users email'
    assert_not current_user.authenticate?('password'), 'Should not still have password'
    assert current_user.authenticate?('Password'), 'Should have updated password'

    # Make sure dont have to update password?
    authorized_patch current_user, users_url, params: { password: 'Password', user: to_update.slice(:username) }

    current_user.reload
    assert_not current_user.authenticate?('password'), 'Should not still have password'
    assert current_user.authenticate?('Password'), 'Should have updated password'

    to_update[:password_confirmation] = nil
    authorized_patch current_user, users_url, params: { password: 'Password', user: to_update }
    assert_response :unprocessable_entity, 'Should be unprocessable_entity for a error'
    assert_response_error "can't be blank", 'password_confirmation'
  end

  test "should create reset password token" do
    user = users(:some_great_user)
    get forgot_password_users_url, params: { email: user.email }
    assert_response :success

    user.reload
    assert_equal 0, user.password_reset_token_attempts, 'Should set to 0'
    assert user.password_reset_token_digest.present?, 'Password reset token should be present'
  end

  test "should not create reset password token for fake user" do
    user = users(:some_great_user)
    get forgot_password_users_url, params: { login:  user.username }
    assert_response :success

    user.reload
    assert_nil user.password_reset_token_attempts, 'password_reset_token_attempts should be nil since email not found'
    assert_nil user.password_reset_token_digest, 'password_reset_token_digest should be nil since email not found'
  end

  test "should not reset reset password token unless admin" do
    user = some_great_user_with_password_reset_token(attempts: 2)
    get admin_forgot_password_users_url, params: { email: user.email }
    assert_response :unauthorized

    user.reload
    assert_equal 2, user.password_reset_token_attempts, 'Should not reset'

    authorized_get user, admin_forgot_password_users_url, params: { email: user.email }
    assert_response :forbidden

    user.reload
    assert_equal 2, user.password_reset_token_attempts, 'Should not reset'

    authorized_get users(:some_great_admin_user), admin_forgot_password_users_url, params: { email: user.email }
    assert_response :success

    user.reload
    assert_equal 0, user.password_reset_token_attempts, 'Should reset to 0'
  end

  test "should reset password token" do
    user = some_great_user_with_password_reset_token
    params = {
      email: user.email, reset_token: 'token', new_password: 'new_password', new_password_confirmation: 'new_password'
    }
    get reset_password_users_url, params: params
    assert_response :success

    assert_password_reset_token(user, 'new_password')
  end

  test "should not reset password token even if user missing information" do
    user = some_great_user_with_password_reset_token
    user.username = nil
    user.save(validate: false)

    params = {
      email: user.email, reset_token: 'token', new_password: 'new_password', new_password_confirmation: 'new_password'
    }
    get reset_password_users_url, params: params
    assert_response :unprocessable_entity

    assert_not_password_reset_token(user, 'password')
    assert_equal [], parsed_response['errors'].keys, 'should only return these keys'
  end

  test "should not get success for fake user" do
    user = some_great_user_with_password_reset_token
    params = {
      email: user.username, reset_token: 'not_token', new_password: 'new_password', new_password_confirmation: 'password'
    }
    get reset_password_users_url, params: params
    assert_response :unprocessable_entity

    assert_response_error("doesn't match Password", 'password_confirmation')
    assert_response_error("doesn't match email", 'password_reset_token')
    assert_equal ['password_confirmation', 'password_reset_token'], parsed_response['errors'].keys, 'should only return these keys'
  end

  test "should not reset password token" do
    user = some_great_user_with_password_reset_token
    params = {
      email: user.email, reset_token: 'not_token', new_password: 'new_password', new_password_confirmation: 'password'
    }
    get reset_password_users_url, params: params
    assert_response :unprocessable_entity

    assert_not_password_reset_token(user, 'password')

    assert_response_error("doesn't match Password", 'password_confirmation')
    assert_response_error("doesn't match email", 'password_reset_token')
    assert_equal ['password_confirmation', 'password_reset_token'], parsed_response['errors'].keys, 'should only return these keys'
  end

  def assert_not_password_reset_token(user, old_password, maxed: false)
    attempts = user.password_reset_token_attempts + 1 unless maxed

    user.reload
    assert user.authenticate(old_password), 'Should not have change password'
    assert user.password_reset_token_digest, 'Should have a password_reset_token_digest'
    assert_equal attempts, user.password_reset_token_attempts, 'Should have a increased password_reset_token'
  end

  def assert_password_reset_token(user, password)
    user.reload
    assert user.authenticate(password), 'Should not have change password'
    assert_nil user.password_reset_token_digest, 'Should not have a password_reset_token'
    assert_nil user.password_reset_token_attempts, 'Should not have a password_reset_token_attempts'
  end

  def some_great_user_with_password_reset_token(token: 'token', attempts: 0)
    user = users(:some_great_user)
    user.update!(
      password_reset_token_digest: BCrypt::Password.create(token),
      password_reset_token_attempts: attempts
    )
    user
  end
end
