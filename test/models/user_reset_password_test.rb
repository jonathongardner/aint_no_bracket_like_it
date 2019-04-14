# frozen_string_literal: true

require 'test_helper'
class UserResetPasswordTest < ActiveSupport::TestCase
  test "should create password_reset_token when forgot_password" do
    user = users(:some_great_user)
    create_session(user)

    assert_nil user.reset_password_token_digest, 'Should not have a password_reset_token'
    assert_nil user.reset_password_attempts, 'Should not have a reset_password_attempts'

    user.forgot_password
    user.reload # should be saved

    assert user.reset_password_token_digest, 'Should set password_reset_token to random token'
    assert_equal 0, user.reset_password_attempts, 'Should set reset_password_attempts to 0'
    assert_equal 0, user.sessions.count, 'Should clear session when password forgot'
  end

  test "should not create password_reset_token if not valid" do
    user = users(:some_great_user)
    user.username = nil
    user.save(validate: false)

    assert_nil user.reset_password_token_digest, 'Should not have a reset_password_token_digest'
    assert_nil user.reset_password_attempts, 'Should not have a reset_password_attempts'

    user.forgot_password
    user.reload # should be saved

    assert_nil user.reset_password_token_digest, 'Should not have a reset_password_token_digest'
    assert_nil user.reset_password_attempts, 'Should not have a reset_password_attempts'
  end

  test "should remove reset_password_token if successful login" do
    # TODO Think about allowing login and reseting this if they do login after this is requested
    user = some_great_user_with_reset_password_token

    assert user.reset_password_token_digest.present?, 'Should have a reset_password_token_digest'
    assert user.reset_password_attempts.present?, 'Should have a reset_password_attempts'

    assert user.authenticate?('password')
    assert user.create_token(false)

    assert_nil user.reset_password_token_digest, 'Should not have a reset_password_token_digest'
    assert_nil user.reset_password_attempts, 'Should not have a reset_password_attempts'
  end

  test "should not save user without both password_reset_token and reset_password_attempts" do
    user = users(:some_great_user)
    user.reset_password_token_digest = 'something'
    assert_not user.save, 'Saved without reset_password_attempts'
    assert_error_message "can't be blank if password_reset_token is present", user, :reset_password_attempts
    assert_number_of_errors 1, user

    user.reset_password_token_digest = nil
    user.reset_password_attempts = 0
    assert_not user.save, 'Saved without reset_password_attempts'
    assert_error_message "can't be present if password_reset_token is blank", user, :reset_password_attempts
    assert_number_of_errors 1, user
  end

  test "should not validate_password_reset_token for wrong token" do
    user = some_great_user_with_reset_password_token
    user.reset_password(reset_token: 'bad_token', new_password: 'new_password', new_password_confirmation: 'new_password')

    assert_not user.save, 'Should not save reset token for wrong token'
    assert_not_password_reset_token user, 'password'
  end

  test "should raise error when using reset_password!" do
    user = some_great_user_with_reset_password_token
    assert_raise(ActiveRecord::RecordInvalid) do
      User.reset_password!(user.email, reset_token: 'bad_token', new_password: 'new_password', new_password_confirmation: 'new_password')
    end
  end

  test "should not skip validation when using reset_password" do
    user = some_great_user_with_reset_password_token
    user.reset_password(reset_token: nil, new_password: 'new_password', new_password_confirmation: 'new_password')

    assert_not user.save, 'Should not save reset token for wrong token'
    assert_not_password_reset_token user, 'password'
  end

  test "should not validate_password_reset_token for already exhausted token attempts" do
    user = some_great_user_with_reset_password_token(attempts: User::MAX_RESET_PASSWORD_ATTEMPTS)
    user.reset_password(reset_password_token: 'bad_token', new_password: 'new_password', new_password_confirmation: 'new_password')

    assert_not user.save, 'Should not save reset token for wrong token'

    assert_not_password_reset_token user, 'password'
  end

  test "should not update if confirmation password doesnt match" do
    user = some_great_user_with_reset_password_token
    user.reset_password(reset_password_token: 'token', new_password: 'new_password', new_password_confirmation: 'different_new_password')

    assert_not user.save, 'Should not save reset token for confirmation password not matching'

    assert_error_message "doesn't match Password", user, :password_confirmation
    assert_number_of_errors 1, user
  end

  test "should not update if confirmation password doesnt match and bad_token" do
    user = some_great_user_with_reset_password_token
    user.reset_password(reset_password_token: 'bad_token', new_password: 'new_password', new_password_confirmation: 'different_new_password')

    assert_not user.save, 'Should not save reset token for confirmation password not matching and bad_token'

    assert_error_message "doesn't match Password", user, :password_confirmation
    assert_not_password_reset_token user, 'password', errors: 2
  end

  test "should not update/create if new user" do
    user = User.new
    user.reset_password(reset_password_token: 'bad_token', new_password: 'new_password', new_password_confirmation: 'different_new_password')

    assert_not user.save, 'Should not save if new user'

    assert_error_message "doesn't match email", user, :reset_password_token
  end

  test "should validate_password_reset_token for correct token and update password" do
    user = some_great_user_with_reset_password_token(attempts: User::MAX_RESET_PASSWORD_ATTEMPTS - 1)
    user.reset_password(reset_password_token: 'token', new_password: 'new_password', new_password_confirmation: 'new_password')

    assert user.save, 'Didnt save correct token'

    assert user.authenticate?('new_password'), 'Should have change password'
    assert_nil user.reset_password_token_digest, 'Should not have a reset_password_token_digest'
    assert_nil user.reset_password_attempts, 'Should not have a reset_password_attempts'
  end

  test "should increase user reset_password_attempts" do
    user = some_great_user_with_reset_password_token
    failed_user = User.failed_reset_password_attempt(user.email)
    assert_equal user.reset_password_attempts + 1, failed_user.reset_password_attempts
  end

  test "should not increase user reset_password_attempts if maxed" do
    user = some_great_user_with_reset_password_token(attempts: User::MAX_RESET_PASSWORD_ATTEMPTS)
    failed_user = User.failed_reset_password_attempt(user.email)
    assert_equal user.reset_password_attempts, failed_user.reset_password_attempts
  end

  test "should not raise error if missing data" do
    user = some_great_user_with_reset_password_token
    user.username = nil
    user.save(validate: false)
    failed_user = User.failed_reset_password_attempt(user.email)
    assert_equal user.reset_password_attempts + 1, failed_user.reload.reset_password_attempts
  end

  def assert_not_password_reset_token(user, old_password, errors: 1)
    assert_error_message "doesn't match email", user, :reset_password_token
    assert_number_of_errors errors, user

    user.reload
    assert user.authenticate(old_password), 'Should not have change password'
    assert user.reset_password_token_digest, 'Should have a reset_password_token_digest'
  end

  def some_great_user_with_reset_password_token(token: 'token', attempts: 0)
    user = users(:some_great_user)
    user.update!(
      reset_password_token_digest: BCrypt::Password.create(token),
      reset_password_attempts: attempts
    )
    user
  end

  def create_session(user)
    new_token = user.create_token(true)
    assert_equal 1, user.sessions.count, 'Should have one session'
  end
end
