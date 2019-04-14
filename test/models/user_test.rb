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
    assert_equal 0, user.sessions.count, 'Should clear session when password updated'
  end
  test "should not clear user sessions if password update fails" do
    user = users(:some_great_user)
    create_session(user)

    assert_not user.update(password: 'Password'), 'Updated user without password_confirmation'
    assert_error_message "can't be blank", user, :password_confirmation
    assert_number_of_errors 1, user
    assert_equal 1, user.sessions.count, 'Should not clear session when password updated fails'
  end
  test "should not clear user sessions if password not updated" do
    user = users(:some_great_user)
    create_session(user)

    user.update!(username: 'new_username')
    assert_equal 1, user.sessions.count, 'Should not clear session when password not updated'
  end
  test "should create user" do
    new_user = User.new(
      email: 'email@somewhere.com', username: 'username', password: 'Password', password_confirmation: 'Password'
    )
    assert new_user.save, 'Did not save new user with correct info'
    assert new_user.email_confirmation_token_digest.present?, 'Should create email_confirmation_token_digest'
  end

  test "should not return password, password_digest, password_reset_token_digest, or password_reset_token_attempts in json" do
    secret_columns = ['password', 'password_digest', 'password_reset_token_digest', 'password_reset_token_attempts']
    keys_found = users(:some_great_user).as_json.keys & secret_columns
    assert_empty keys_found, 'found secret keys in json'
  end

  #-----------------------Email Confirmation-------------------------------
  test "should update user with email" do
    user = users(:some_great_user)
    user.update!(username: 'some_new_name')

    assert user.email_confirmation_token_digest.blank?, 'Should not create email_confirmation_token_digest if email not updated'

    user.update!(email: 'some_new_name@soemwhere.com')

    assert user.email_confirmation_token_digest.present?, 'Should create email_confirmation_token_digest if email updated'
  end

  test "should not update unless valid email_confirmation" do
    user = some_great_user_with_email_confirmation_token

    assert_not user.update(email_confirmation_token: nil), 'Updated without valid email_confirmation_token'
    assert_error_message "doesn't match", user, :email_confirmation_token
    assert_number_of_errors 1, user

    assert user.update(email_confirmation_token: 'token'), 'Didnt update with valid email_confirmation_token'
  end

  def some_great_user_with_email_confirmation_token(token: 'token')
    user = users(:some_great_user)
    user.update!(
      email_confirmation_token_digest: BCrypt::Password.create(token)
    )
    user
  end

  #-----------------------Email Confirmation-------------------------------

  def create_session(user)
    new_token = user.create_token(true)
    assert_equal 1, user.sessions.count, 'Should have one session'
  end
end
