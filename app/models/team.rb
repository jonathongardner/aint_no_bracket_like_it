# frozen_string_literal: true

class Team < ApplicationRecord
  has_many :tournamet_teams
  STATES = [
    "AL", "AK", "AZ", "AR", "AA", "AE", "AP", "CA", "CO", "CT", "DE", "DC", "FL", "GA", "HI", "ID", "IL", "IN",
    "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY",
    "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"
  ]
  validates :name, :city, :state, presence: true
  validates :name, uniqueness: {case_sensitive: false}
  validates :state, inclusion: {in: STATES, message: 'must be a valid state code'}
end
