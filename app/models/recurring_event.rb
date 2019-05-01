class RecurringEvent < ApplicationRecord
  has_many :event_requests
  has_many :requests, through: :event_requests
end
