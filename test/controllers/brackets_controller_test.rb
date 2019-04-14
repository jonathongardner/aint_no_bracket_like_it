# frozen_string_literal: true

require 'test_helper'
class BracketsControllerTest < ActionDispatch::IntegrationTest
  test "should get bracket for 2017" do
    get bracket_url(2017)
    assert_response :success
    assert_equal 93, parsed_response["7"]["top"]["score"], 'Should return top team score for the real usc vs marquette'
    assert_equal 'Gonzaga Bulldogs', parsed_response["63"]["top"]["name"], 'Should return top team score for final game'
  end
  test "should return :not_found for bracket_url if year that doesnt exist" do
    get bracket_url(1)
    assert_response :not_found
  end
  # test "should get bracket for 2019" do
  #   get bracket_url(2019)
  #   assert_response :success
  #   assert_equal({}, parsed_response, 'Should return empty bracket')
  # end
  test "should get initial bracket for 2017" do
    get initial_bracket_url(2017)
    assert_response :success
    assert_nil parsed_response.dig("7", "top", "score"), 'Should not return scores for initial'
    games = parsed_response.keys.map(&:to_i).sort
    assert_equal 32, games.length, 'Should return the first 32 games'
    assert_equal 1, games.first, 'Should return the first game'
    assert_equal 32, games.last, 'Should return the last game'
  end
  test "should return :not_found for initial_bracket_url if year that doesnt exist" do
    get initial_bracket_url(1)
    assert_response :not_found
  end
  test "should get bracket stats for game 7" do
    get bracket_stats_url(7)
    assert_response :success

    assert_equal([{"rank" => 7, "count" => 1}], parsed_response['commonTopRank'], 'Should return rank 7 and count 1')
    assert_equal([{"rank" => 10, "count" => 1}], parsed_response['commonBottomRank'], 'Should return rank 10 and count 1')
    assert_equal([{"topRank" => 7, "bottomRank" => 10, "count" => 1}], parsed_response['commonMatchUps'], 'Should return rank 7 and 10 and count 1')
  end
  test "should return :not_found for bracket_stats_url if game doesnt exist" do
    get bracket_stats_url(-1)
    assert_response :not_found
    get bracket_stats_url(0)
    assert_response :success
    get bracket_stats_url(63)
    assert_response :success
    get bracket_stats_url(64)
    assert_response :not_found
  end
  #----------------------Authentication--------------------------
  test "should have correct authentication for bracket_url" do
    assert_authentication_response(:anyone) do |current_user|
      authorized_get current_user, bracket_url(2017)
    end
  end

  test "should have correct authentication for unique_brackets_url index" do
    assert_authentication_response(:anyone) do |current_user|
      authorized_get current_user, initial_bracket_url(2017)
    end
  end

  test "should have correct authentication for unique_brackets_url show" do
    assert_authentication_response(:anyone) do |current_user|
      authorized_get current_user, bracket_stats_url(7)
    end
  end
end
