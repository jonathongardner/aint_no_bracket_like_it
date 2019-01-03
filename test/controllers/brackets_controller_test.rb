# frozen_string_literal: true

require 'test_helper'
class BracketsControllerTest < ActionDispatch::IntegrationTest
  test "should get bracket for 2017" do
    get bracket_url(2017)
    assert_response :success
    assert_equal 93, parsed_response["7"]["top_team_score"], 'Should return top team score for the real usc vs marquette'
    assert_equal 'Gonzaga Bulldogs', parsed_response["63"]["top_tournament_team"]["team"]["name"], 'Should return top team score for final game'
  end
  test "should get bracket for 2019" do
    get bracket_url(2019)
    assert_response :success
    assert_equal({}, parsed_response, 'Should return empty bracket')
  end
end
