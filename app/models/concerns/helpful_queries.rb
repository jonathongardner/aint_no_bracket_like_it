# frozen_string_literal: true

module HelpfulQueries
  extend ActiveSupport::Concern

  def update_self!(*options)
    self.update!(*options)
    self
  end

  module ClassMethods
    def update!(id, *options)
      self.find(id).update_self!(*options)
    end
  end
end
