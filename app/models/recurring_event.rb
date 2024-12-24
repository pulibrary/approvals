# frozen_string_literal: true

class RecurringEvent < ApplicationRecord
  has_many :event_requests, dependent: :destroy
  has_many :requests, through: :event_requests

  validates :name, presence: true
end
