# frozen_string_literal: true

require 'test_helper'
class TeamTest < ActiveSupport::TestCase
  test "should not create team without name, city, or state" do
    new_team = Team.new
    assert_not new_team.save, 'Saved new team without name, city and state'
    assert_error_message "can't be blank", new_team, :name, :city, :state
    assert_number_of_errors 3, new_team
  end
  test "should not create team without unique name" do
    new_team = Team.new(name: teams(:duke).name, city: 'somewhere', state: 'CA')
    assert_not new_team.save, 'Saved new team without unique name'
    assert_error_message "has already been taken", new_team, :name
    assert_number_of_errors 1, new_team
  end
  test "should not create team without state code in list" do
    new_team = Team.new(name: 'SomeName', city: 'somewhere', state: 'NW')
    assert_not new_team.save, 'Saved new team without state code in list'
    assert_error_message "must be a valid state code", new_team, :state
    assert_number_of_errors 1, new_team
  end
  test "should create team" do
    new_team = Team.new(name: 'SomeName', city: 'somewhere', state: 'NC')
    assert new_team.save, 'Did not save new team with correct info'
  end
end
