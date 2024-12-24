# frozen_string_literal: true

class EventAttendees
  class << self
    def list(recurring_event:, event_start_date:, window: 1.week)
      start_window = event_start_date - window
      end_window = event_start_date + window
      event_requests = EventRequest.where(recurring_event:, start_date: start_window..end_window)
      event_requests.map { |event_request| event_request.request.creator }
    end
  end
end
