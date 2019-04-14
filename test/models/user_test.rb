# frozen_string_literal: true

require 'test_helper'
class UserTest < ActiveSupport::TestCase
  test "should not create user without email, username, or password" do
    new_user = User.new
    assert_not new_user.save, 'Saved new user without email, username and password'
    assert_error_message "can't be blank", new_user, :email, :username, :password
    assert_number_of_errors 3, new_user
  end
  test "should not create user without unqiue email and username" do
    new_user = users(:some_great_user).dup
    new_user.username.swapcase!
    new_user.email.swapcase!
    assert_not new_user.save, 'Saved new user without unqiue email and username'
    assert_error_message "has already been taken", new_user, :email, :username
    assert_number_of_errors 2, new_user
  end
  test "should not create user without email that follows email format" do
    new_user = User.new(
      email: 'email@', username: 'username', password: 'Password', password_confirmation: 'Password'
    )
    assert_not new_user.save, 'Saved new user without email that follows format'
    assert_error_message "didn't match login criteria", new_user, :email
    assert_number_of_errors 1, new_user
  end
  test "should not create user without password_confirmation" do
    new_user = User.new(email: 'email@somewhere.com', username: 'username', password: 'Password')
    assert_not new_user.save, 'Saved new user without password_confirmation'
    assert_error_message "can't be blank", new_user, :password_confirmation
    assert_number_of_errors 1, new_user
  end
  test "should clear user sessions when password updated" do
    user = users(:some_great_user)
    create_session(user)

    user.update!(password: 'Password', password_confirmation: 'Password')
    assert_equal 0, user.sessions.count, 'Should clear session when password forgot'
  end
  test "should not clear user sessions if password update fails" do
    user = users(:some_great_user)
    create_session(user)

    assert_not user.update(password: 'Password'), 'Updated user without password_confirmation'
    assert_error_message "can't be blank", user, :password_confirmation
    assert_number_of_errors 1, user
    assert_equal 1, user.sessions.count, 'Should clear session when password forgot'
  end
  test "should not clear user sessions if password not updated" do
    user = users(:some_great_user)
    create_session(user)

    user.update!(username: 'new_username')
    assert_equal 1, user.sessions.count, 'Should clear session when password forgot'
  end
  test "should create user" do
    new_user = User.new(
      email: 'email@somewhere.com', username: 'username', password: 'Password', password_confirmation: 'Password'
    )
    assert new_user.save, 'Did not save new user with correct info'
  end

  test "should not return password, password_digest, password_reset_token_digest, or password_reset_token_attempts in json" do
    secret_columns = ['password', 'password_digest', 'password_reset_token_digest', 'password_reset_token_attempts']
    keys_found = users(:some_great_user).as_json.keys & secret_columns
    assert_empty keys_found, 'found secret keys in json'
  end
  #---------------------------password reset token--------------------------
  test "should create password_reset_token when forgot_password" do
    user = users(:some_great_user)
    create_session(user)

    assert_nil user.password_reset_token_digest, 'Should not have a password_reset_token'
    assert_nil user.password_reset_token_attempts, 'Should not have a password_reset_token_attempts'

    User.forgot_password(user.email)
    user.reload # should be saved

    assert user.password_reset_token_digest, 'Should set password_reset_token to random token'
    assert_equal 0, user.password_reset_token_attempts, 'Should set password_reset_token_attempts to 0'
    assert_equal 0, user.sessions.count, 'Should clear session when password forgot'
  end
  test "should not create password_reset_token when forgot_password" do
    user = users(:some_great_user)
    assert_nil user.password_reset_token_digest, 'Should not have a password_reset_token'
    assert_nil user.password_reset_token_attempts, 'Should not have a password_reset_token_attempts'

    User.forgot_password(user.username)
    user.reload # should be saved

    assert_nil user.password_reset_token_digest, 'Should not have a password_reset_token'
    assert_nil user.password_reset_token_attempts, 'Should not have a password_reset_token_attempts'
  end

  test "should create password_reset_token if already set and reset passed" do
    user = some_great_user_with_password_reset_token(attempts: 1)

    User.forgot_password(user.email, reset: true)
    user.reload # should be saved

    assert BCrypt::Password.new(user.password_reset_token_digest) != 'token', 'Should reset password_reset_token_digest to random token'
    assert_equal 0, user.password_reset_token_attempts, 'Should reset password_reset_token_attempts to 0'
  end

  test "should not create password_reset_token if already set" do
    user = some_great_user_with_password_reset_token(attempts: 1)

    User.forgot_password(user.email)
    user.reload # should be saved

    assert BCrypt::Password.new(user.password_reset_token_digest) == 'token', 'Should not reset password_reset_token_digest to random token'
    assert_equal 1, user.password_reset_token_attempts, 'Should not reset password_reset_token_attempts to 0'
  end

  test "should not create password_reset_token if not valid" do
    user = users(:some_great_user)
    user.username = nil
    user.save(validate: false)

    assert_nil user.password_reset_token_digest, 'Should not have a password_reset_token_digest'
    assert_nil user.password_reset_token_attempts, 'Should not have a password_reset_token_attempts'

    User.forgot_password(user.email)
    user.reload # should be saved

    assert_nil user.password_reset_token_digest, 'Should not have a password_reset_token_digest'
    assert_nil user.password_reset_token_attempts, 'Should not have a password_reset_token_attempts'
  end

  test "should not allow authentication when token password_reset_token exists" do
    # TODO Think about allowing login and reseting this if they do login after this is requested
    user = some_great_user_with_password_reset_token
    assert user.authenticate('password')
    assert_not user.authenticate?('password'), 'Allowed user with password_reset_token to authenticate'
  end

  test "should not save user without both password_reset_token and password_reset_token_attempts" do
    user = users(:some_great_user)
    user.password_reset_token_digest = 'something'
    assert_not user.save, 'Saved without password_reset_token_attempts'
    assert_error_message "can't be blank if password_reset_token is present", user, :password_reset_token_attempts
    assert_number_of_errors 1, user

    user.password_reset_token_digest = nil
    user.password_reset_token_attempts = 0
    assert_not user.save, 'Saved without password_reset_token_attempts'
    assert_error_message "can't be present if password_reset_token is blank", user, :password_reset_token_attempts
    assert_number_of_errors 1, user
  end

  test "should not validate_password_reset_token for wrong token" do
    user = some_great_user_with_password_reset_token
    user.reset_password(reset_token: 'bad_token', new_password: 'new_password', new_password_confirmation: 'new_password')

    assert_not user.save, 'Should not save reset token for wrong token'
    assert_not_password_reset_token user, 'password'
  end

  test "should raise error when using reset_password!" do
    user = some_great_user_with_password_reset_token
    assert_raise(ActiveRecord::RecordInvalid) do
      User.reset_password!(user.email, reset_token: 'bad_token', new_password: 'new_password', new_password_confirmation: 'new_password')
    end
  end

  test "should not skip validation when using reset_password" do
    user = some_great_user_with_password_reset_token
    user.reset_password(reset_token: nil, new_password: 'new_password', new_password_confirmation: 'new_password')

    assert_not user.save, 'Should not save reset token for wrong token'
    assert_not_password_reset_token user, 'password'
  end

  test "should not validate_password_reset_token for already exhausted token attempts" do
    user = some_great_user_with_password_reset_token(attempts: User::MAX_RESET_PASSWORD_ATTEMPTS)
    user.reset_password(reset_token: 'bad_token', new_password: 'new_password', new_password_confirmation: 'new_password')

    assert_not user.save, 'Should not save reset token for wrong token'

    assert_not_password_reset_token user, 'password'
  end

  test "should not update if confirmation password doesnt match" do
    user = some_great_user_with_password_reset_token
    user.reset_password(reset_token: 'token', new_password: 'new_password', new_password_confirmation: 'different_new_password')

    assert_not user.save, 'Should not save reset token for confirmation password not matching'

    assert_error_message "doesn't match Password", user, :password_confirmation
    assert_number_of_errors 1, user
  end

  test "should not update if confirmation password doesnt match and bad_token" do
    user = some_great_user_with_password_reset_token
    user.reset_password(reset_token: 'bad_token', new_password: 'new_password', new_password_confirmation: 'different_new_password')

    assert_not user.save, 'Should not save reset token for confirmation password not matching and bad_token'

    assert_error_message "doesn't match Password", user, :password_confirmation
    assert_not_password_reset_token user, 'password', errors: 2
  end

  test "should not update/create if new user" do
    user = User.new
    user.reset_password(reset_token: 'bad_token', new_password: 'new_password', new_password_confirmation: 'different_new_password')

    assert_not user.save, 'Should not save if new user'

    assert_error_message "doesn't match email", user, :password_reset_token
  end

  test "should validate_password_reset_token for correct token and update password" do
    user = some_great_user_with_password_reset_token(attempts: User::MAX_RESET_PASSWORD_ATTEMPTS - 1)
    user.reset_password(reset_token: 'token', new_password: 'new_password', new_password_confirmation: 'new_password')

    assert user.save, 'Didnt save correct token'

    assert user.authenticate?('new_password'), 'Should have change password'
    assert_nil user.password_reset_token_digest, 'Should not have a password_reset_token_digest'
    assert_nil user.password_reset_token_attempts, 'Should not have a password_reset_token_attempts'
  end

  test "should increase user password_reset_token_attempts" do
    user = some_great_user_with_password_reset_token
    failed_user = User.failed_password_reset_attempt(user.email)
    assert_equal user.password_reset_token_attempts + 1, failed_user.password_reset_token_attempts
  end

  test "should not increase user password_reset_token_attempts if maxed" do
    user = some_great_user_with_password_reset_token(attempts: User::MAX_RESET_PASSWORD_ATTEMPTS)
    failed_user = User.failed_password_reset_attempt(user.email)
    assert_equal user.password_reset_token_attempts, failed_user.password_reset_token_attempts
  end

  test "should not raise error if missing data" do
    user = some_great_user_with_password_reset_token
    user.username = nil
    user.save(validate: false)
    failed_user = User.failed_password_reset_attempt(user.email)
    assert_equal user.password_reset_token_attempts + 1, failed_user.reload.password_reset_token_attempts
  end

  def assert_not_password_reset_token(user, old_password, errors: 1)
    assert_error_message "doesn't match email", user, :password_reset_token
    assert_number_of_errors errors, user

    user.reload
    assert user.authenticate(old_password), 'Should not have change password'
    assert user.password_reset_token_digest, 'Should have a password_reset_token_digest'
  end

  def some_great_user_with_password_reset_token(token: 'token', attempts: 0)
    user = users(:some_great_user)
    user.update!(
      password_reset_token_digest: BCrypt::Password.create(token),
      password_reset_token_attempts: attempts
    )
    user
  end

  def create_session(user)
    new_token = user.create_token(true)
    assert_equal 1, user.sessions.count, 'Should have one session'
  end
end
