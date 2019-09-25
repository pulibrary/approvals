# frozen_string_literal: true
class EventRequestChangeSet < Reform::Form
  property :start_date
  property :end_date
  property :recurring_event_id
  property :location

  validates :recurring_event_id, :start_date, :location, presence: true

  validate :recurring_event_id do
    if recurring_event_id.present?
      errors.add(:recurring_event_id, "must be a RecurringEvent") if recurring_event.blank?
    end
  end

  def prepopulate!(options)
    super(options)
    self.start_date = Time.zone.today.to_date
  end

  EventRequestPopulator = lambda { |collection:, **|
    if collection.empty?
      collection.append(EventRequest.new)
    else
      collection.first
    end
  }

  EventRequestPrepopulator = lambda { |**|
    event_requests.append(EventRequest.new) if event_requests.empty?
  }

  def recurring_event
    return nil if recurring_event_id.blank?

    ::RecurringEvent.find_by(id: recurring_event_id.to_i)
  end
end
