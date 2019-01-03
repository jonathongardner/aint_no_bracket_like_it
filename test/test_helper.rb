ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'helpers/extra_asserts'
require 'helpers/response'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include ExtraAsserts, Response

  # Add more helper methods to be used by all tests here...
end
