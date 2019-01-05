# frozen_string_literal: true

require 'test_helper'
class BracketsControllerTest < ActionDispatch::IntegrationTest
  test "should get bracket for 2017" do
    get bracket_url(2017)
    assert_response :success
    assert_equal 93, parsed_response["7"]["top"]["score"], 'Should return top team score for the real usc vs marquette'
    assert_equal 'Gonzaga Bulldogs', parsed_response["63"]["top"]["name"], 'Should return top team score for final game'
  end
  test "should get bracket for 2019" do
    get bracket_url(2019)
    assert_response :success
    assert_equal({}, parsed_response, 'Should return empty bracket')
  end
  test "should get initial bracket for 2017" do
    get initial_bracket_url(2017)
    assert_response :success
    assert_nil parsed_response.dig("7", "top", "score"), 'Should not return scores for initial'
    games = parsed_response.keys.map(&:to_i).sort
    assert_equal 32, games.length, 'Should return the first 32 games'
    assert_equal 1, games.first, 'Should return the first game'
    assert_equal 32, games.last, 'Should return the last game'
  end
end
