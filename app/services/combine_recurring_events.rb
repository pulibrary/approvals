# frozen_string_literal: true
require "csv"

class CombineRecurringEvents
  class << self
    def process(combined_name:, selected_event_ids:)
      return unless selected_event_ids.count > 1

      first_event_id = selected_event_ids.shift
      first_event = RecurringEvent.find(first_event_id)
      first_event.name = name
      first_event.save!
      selected_event_ids.each do |event_id|
        combine(first_event: first_event, event_id: event_id)
      end
    end

    private

      def combine(first_event:, event_id:)
        event = RecurringEvent.find(event_id)
        EventRequest.where(recurring_event_id: event_id).each do |event_request|
          event_request.recurring_event = first_event
          event_request.save!
        end
        event.destroy
      end
  end
end
