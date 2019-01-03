# frozen_string_literal: true

class Team < ApplicationRecord
  has_many :tournament_teams
  STATES = [
    "Alabama", "Alaska", "Arizona", "Arkansas", "Armed Forces America", "Armed Forces Europe", "Armed Forces Pacific", "California",
    "Colorado", "Connecticut", "Delaware", "District of Columbia", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana",
    "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri",
    "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio",
    "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont",
    "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"
  ]
  validates :name, :city, :state, presence: true
  validates :name, uniqueness: {case_sensitive: false}
  validates :state, inclusion: {in: STATES, message: 'must be a valid state'}
end
