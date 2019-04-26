class Event < ApplicationRecord
  belongs_to :recurring_event, optional: true
end
