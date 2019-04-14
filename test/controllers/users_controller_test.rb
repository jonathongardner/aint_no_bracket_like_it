# frozen_string_literal: true

require 'test_helper'
class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should create user" do
    to_create = {
      email: 'email@somewhere.com', username: 'username',
      password: 'Password', password_confirmation: 'Password'
    }
    assert_difference('User.count') do
      post users_url, params: { user: to_create }
      assert_response :success
    end
  end

  test "should not create user if errors" do
    to_create = {
      email: users(:some_great_user).email, username: 'username',
      password: 'Password', password_confirmation: 'Password'
    }

    assert_no_difference('User.count') do
      post users_url, params: { user: to_create }
      assert_response :unprocessable_entity, 'Should be unprocessable_entity for a error'
    end
    assert_response_error "has already been taken", 'email'
  end

  test "should update user for current_user" do
    to_update = {
      email: 'new_email', username: 'new_username', password: 'Password', password_confirmation: 'Password'
    }
    current_user = users(:some_great_user)

    authorized_patch current_user, users_url, params: { user: to_update }
    assert_response :unauthorized, 'Should be unauthorized if no password sent'

    authorized_patch current_user, users_url, params: { password: 'password', user: to_update }
    assert_response :success

    current_user.reload
    refute_equal to_update[:email], current_user.email, 'Should not update users email'
    assert current_user.authenticate?('Password'), 'Should have updated password'

    # Make sure dont have to update password?
    authorized_patch current_user, users_url, params: { password: 'Password', user: to_update.slice(:username) }

    current_user.reload
    assert current_user.authenticate?('Password'), 'Should have updated password'
  end

  test "should not update user for current_user if errors" do
    authorized_patch users(:some_great_user), users_url, params: { password: 'password', user: { password: 'Password' } }
    assert_response :unprocessable_entity, 'Should be unprocessable_entity for a error'
    assert_response_error "can't be blank", 'password_confirmation'
  end

  #----------------Email Verification-------------------
  test "should validate_email for unvalidated_unapproved_email_user" do
    current_user = users(:unvalidated_unapproved_email_user)

    authorized_patch current_user, validate_email_users_url, params: { email_confirmation_token: 'token' }
    assert_response :success

    current_user.reload
    assert_nil current_user.email_confirmation_token_digest, 'Should remove email_confirmation_token_digest'
  end

  test "should not validate_email for no_user or wrong token" do
    patch validate_email_users_url, params: { email_confirmation_token: 'token' }
    assert_response :unauthorized

    current_user = users(:unvalidated_unapproved_email_user)

    authorized_patch current_user, validate_email_users_url, params: { email_confirmation_token: 'not_token' }
    assert_response :unprocessable_entity, 'Should be unprocessable_entity for a error'
    assert_response_error "doesn't match", 'email_confirmation_token'
  end
  #----------------Email Verification-------------------

  #----------------Password Reset-------------------
  test "should create reset password token" do
    user = users(:some_great_user)
    get forgot_password_users_url, params: { email: user.email }
    assert_response :success

    user.reload
    assert_equal 0, user.reset_password_attempts, 'Should set to 0'
    assert user.reset_password_token_digest.present?, 'Password reset token should be present'
  end

  test "should not reset reset_password_token if already set" do
    user = user_with_password_reset_token(attempts: 2)

    get forgot_password_users_url, params: { email: user.email }
    assert_response :success

    user.reload
    assert_equal 2, user.reset_password_attempts, 'Should not reset to 0'
  end

  test "should not create reset password token for fake user" do
    user = users(:some_great_user)
    get forgot_password_users_url, params: { email:  user.username }
    assert_response :success

    user.reload
    assert_nil user.reset_password_attempts, 'reset_password_attempts should be nil since email not found'
    assert_nil user.reset_password_token_digest, 'reset_password_token_digest should be nil since email not found'
  end

  test "should reset password with token" do
    user = user_with_password_reset_token
    params = {
      email: user.email, reset_password_token: 'token', new_password: 'new_password', new_password_confirmation: 'new_password'
    }
    patch reset_password_users_url, params: params
    assert_response :success

    assert_password_reset_token(user, 'new_password')
  end

  test "should not reset password token if user missing information" do
    user = user_with_password_reset_token
    user.username = nil
    user.save(validate: false)

    params = {
      email: user.email, reset_password_token: 'token', new_password: 'new_password', new_password_confirmation: 'new_password'
    }
    patch reset_password_users_url, params: params
    assert_response :unprocessable_entity

    assert_not_password_reset_token(user, 'password')
    assert_equal [], parsed_response['errors'].keys, 'should only return these keys'
  end

  test "should not get success for fake user" do
    user = user_with_password_reset_token
    params = {
      email: user.username, reset_password_token: 'not_token', new_password: 'new_password', new_password_confirmation: 'password'
    }
    patch reset_password_users_url, params: params
    assert_response :unprocessable_entity

    assert_response_error("doesn't match Password", 'password_confirmation')
    assert_response_error("doesn't match email", 'reset_password_token')
    assert_equal ['password_confirmation', 'reset_password_token'], parsed_response['errors'].keys, 'should only return these keys'
  end

  test "should not reset password with bad token" do
    user = user_with_password_reset_token
    params = {
      email: user.email, reset_password_token: 'not_token', new_password: 'new_password', new_password_confirmation: 'password'
    }
    patch reset_password_users_url, params: params
    assert_response :unprocessable_entity

    assert_not_password_reset_token(user, 'password')

    assert_response_error("doesn't match Password", 'password_confirmation')
    assert_response_error("doesn't match email", 'reset_password_token')
    assert_equal ['password_confirmation', 'reset_password_token'], parsed_response['errors'].keys, 'should only return these keys'
  end

  def assert_not_password_reset_token(user, old_password, maxed: false)
    attempts = user.reset_password_attempts + 1 unless maxed

    user.reload
    assert user.authenticate(old_password), 'Should not have change password'
    assert user.reset_password_token_digest, 'Should have a reset_password_token_digest'
    assert_equal attempts, user.reset_password_attempts, 'Should have a increased password_reset_token'
  end

  def assert_password_reset_token(user, password)
    user.reload
    assert user.authenticate(password), 'Should not have change password'
    assert_nil user.reset_password_token_digest, 'Should not have a password_reset_token'
    assert_nil user.reset_password_attempts, 'Should not have a reset_password_attempts'
  end

  def user_with_password_reset_token(sym = :some_great_user, token: 'token', attempts: 0)
    user = users(sym)
    user.update!(
      reset_password_token_digest: BCrypt::Password.create(token),
      reset_password_attempts: attempts
    )
    user
  end
  #----------------Password Reset-------------------

  test "should have correct authentication for users_url update" do
    assert_authentication_response(:great_user_and_above) do |current_user|
      authorized_patch current_user, users_url, params: { password: 'password', user: {email: 'test'} }
    end
  end
end
