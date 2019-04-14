# frozen_string_literal: true

require 'test_helper'
module Admin
  class UsersControllerTest < ActionDispatch::IntegrationTest
    test "should get users" do
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

    test "should approve users" do
      to_approve = users(:unapproved_user)
      current_user = users(:some_great_admin_user)

      authorized_patch current_user, admin_user_approve_url(user_id: to_approve)
      assert parse_response['approved'], 'Should be approved'

      authorized_patch current_user, admin_user_approve_url(user_id: to_approve, approved: false)
      assert_not parse_response['approved'], 'Should be unapproved'

      authorized_patch current_user, admin_user_approve_url(user_id: to_approve, approved: true)
      assert parse_response['approved'], 'Should be approved'

      authorized_patch current_user, admin_user_approve_url(user_id: to_approve) # Make sure not toggling
      assert parse_response['approved'], 'Should be approved'
    end


    #----------------Password Reset-------------------
    test "should reset reset_password_token" do
      user = user_with_password_reset_token(attempts: 2)

      authorized_get users(:some_great_admin_user), admin_user_forgot_password_url(user_id: user.id)
      assert_response :success

      user.reload
      assert_equal 0, user.reset_password_attempts, 'Should reset to 0'
    end

    def user_with_password_reset_token(token: 'token', attempts: 0)
      user = users(:another_great_user)
      user.update!(
        reset_password_token_digest: BCrypt::Password.create(token),
        reset_password_attempts: attempts
      )
      user
    end
    #----------------Password Reset-------------------

    test "should have correct authentication for users_url index" do
      assert_authentication_response(:admin_only) do |current_user|
        authorized_get current_user, admin_users_url
      end
    end

    test "should have correct authentication for user_approve_url" do
      user_id = users(:unvalidated_unapproved_email_user)
      assert_authentication_response(:admin_only) do |current_user|
        authorized_patch current_user, admin_user_approve_url(user_id: user_id)
      end
    end

    test "should have correct authentication for user_email_confirmation_url" do
      user_id = users(:unvalidated_unapproved_email_user)
      assert_authentication_response(:admin_only) do |current_user|
        authorized_get current_user, admin_user_email_confirmation_url(user_id: user_id)
      end
    end

    test "should have correct authentication for admin_forgot_password_users_url" do
      user = user_with_password_reset_token(attempts: 2)
      assert_authentication_response(:admin_only) do |current_user|
        authorized_get current_user, admin_user_forgot_password_url(user_id: user.id)
      end
    end
  end
end
