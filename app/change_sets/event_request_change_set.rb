# frozen_string_literal: true
class EventRequestChangeSet < Reform::Form
  property :start_date
  property :end_date
  property :recurring_event_id
  property :location

  validates :recurring_event_id, :start_date, :location, presence: true

  validate :recurring_event_id do
    if recurring_event_id.present?
      recurring_event = ::RecurringEvent.find_by(id: recurring_event_id.to_i)
      errors.add(:recurring_event_id, "must be a RecurringEvent") if recurring_event.blank?
    end
  end

  def prepopulate!(options)
    super(options)
    self.start_date = Time.zone.today.to_date
  end

  EventRequestPopulator = lambda { |collection:, **|
    collection.append(EventRequest.new)
  }

  EventRequestPrepopulator = lambda { |**|
    event_requests.append(EventRequest.new) if event_requests.empty?
  }
end
