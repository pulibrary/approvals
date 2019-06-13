# frozen_string_literal: true
class EventRequest < ApplicationRecord
  belongs_to :recurring_event, optional: true
  belongs_to :request
  before_save :update_event_title

  def update_event_title
    request.event_title = "#{recurring_event.name} #{start_date&.year}, #{location}"
    request.save
  end
end
