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
    assert_error_message "incorrect format", new_user, :email
    assert_number_of_errors 1, new_user
  end
  test "should not create user without password_confirmation" do
    new_user = User.new(email: 'email@somewhere.com', username: 'username', password: 'Password')
    assert_not new_user.save, 'Saved new user without password_confirmation'
    assert_error_message "can't be blank", new_user, :password_confirmation
    assert_number_of_errors 1, new_user
  end
  test "should create user" do
    new_user = User.new(
      email: 'email@somewhere.com', username: 'username', password: 'Password', password_confirmation: 'Password'
    )
    assert new_user.save, 'Did not save new user with correct info'
  end
end
