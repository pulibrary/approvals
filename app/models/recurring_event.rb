# frozen_string_literal: true
class RecurringEvent < ApplicationRecord
  has_many :event_requests, dependent: :destroy
  has_many :requests, through: :event_requests

  validates :name, presence: true

  def self.where_contains_text(search_query:)
    # returning all which is the relation
    return all if search_query.blank?

    # search by id
    id_results = Request.where(id: search_query)
    return id_results if id_results.count.positive?

    # escapes the punctuation within the query
    query = connection.quote("%#{search_query}%")
    where("name ilike #{query} ")
  end
end
