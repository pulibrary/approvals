# frozen_string_literal: true

class EventRequest < ApplicationRecord
  belongs_to :recurring_event, optional: true
  belongs_to :request
  before_save :update_event_title

  def update_event_title
    request.event_title = "#{recurring_event.name} #{start_date&.year}, #{location}"
    request.save
  end

  def replace_recurring_event(target_recurring_event:)
    orig_recurring_event = recurring_event

    self.recurring_event = target_recurring_event
    update_event_title
    save!

    orig_recurring_event.destroy if orig_recurring_event.event_requests.empty?
  end
end
