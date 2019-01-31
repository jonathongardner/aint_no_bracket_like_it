# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include HelpfulQueries
  self.abstract_class = true
end
