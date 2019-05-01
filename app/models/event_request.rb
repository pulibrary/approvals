class EventRequest < ApplicationRecord
  belongs_to :recurring_event, optional: true
  belongs_to :request
end
