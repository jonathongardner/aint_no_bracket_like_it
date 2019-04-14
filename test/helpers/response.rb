# frozen_string_literal: true

module Response
  extend ActiveSupport::Concern
  ALL_USERS = [:no_user, :some_great_admin_user, :some_great_user, :unapproved_user, :unvalidated_email_user]

  def parse_response
    # Force update
    @parsed_response = JSON.parse(response.body)
  end
  def parsed_response
    @parsed_response ||= JSON.parse(response.body)
  end

  def returned_token
    response.headers['authorization'][13..-1]
  end

  def assert_new_token(token: current_token)
    assert returned_token, 'Should return a token'
    assert token != returned_token, 'Should return a new token'
  end

  def assert_authentication_response(passed_options)
    is_hash = proc { |v| v.is_a?(Hash) }

    case passed_options
    when is_hash
      options = passed_options
    when :admin_only
      options = {
        unauthorized: [:no_user],
        forbidden: [:unapproved_user, :unvalidated_email_user, :some_great_user],
        success: [:some_great_admin_user]
      }
    when :great_user_and_above
      options = {
        unauthorized: [:no_user],
        forbidden: [:unapproved_user, :unvalidated_email_user],
        success: [:some_great_user, :some_great_admin_user]
      }
    when :great_user_resource
      options = {
        unauthorized: [:no_user],
        forbidden: [:unapproved_user, :unvalidated_email_user],
        success: [:some_great_user],
        not_found: [:some_great_admin_user]
      }
    when :user
      options = {
        unauthorized: [:no_user],
        success: [:unapproved_user, :unvalidated_email_user, :some_great_user, :some_great_admin_user]
      }
    when :anyone
      options = {
        success: [:no_user, :unapproved_user, :unvalidated_email_user, :some_great_user, :some_great_admin_user]
      }
    else
      raise "passed options unknown: #{passed_options}"
    end

    all_users_passed = options.values.flatten.sort
    raise 'Must test all users' unless ALL_USERS == all_users_passed

    options.each do |key, users|
      users.each do |user_sym|
        current_user = user_sym == :no_user ? nil : users(user_sym)
        yield(current_user)
        assert_response key, "Should be #{key} for #{user_sym}"
      end
    end
  end

  module ClassMethods
    def authentication(action, route, params: {}, route_params: {}, **options)
      message_name = "should have correct authentication for #{action} #{route}"
      message_name += " with params #{route_params}" if route_params.present?
      test message_name do
        assert_authentication_response(options) do |current_user|
          send("authorized_#{action}", current_user, send(route, route_params), params: params)
        end
      end
    end
  end
end
