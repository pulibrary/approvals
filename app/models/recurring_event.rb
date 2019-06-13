# frozen_string_literal: true
class RecurringEvent < ApplicationRecord
  has_many :event_requests
  has_many :requests, through: :event_requests

  validates :name, presence: true
end
