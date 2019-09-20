# frozen_string_literal: true
class RandomRequestGenerator
  class << self
    def generate_travel_request(creator:, status: "pending")
      recurring_events = generate_random_recurring_events
      estimates = generate_random_estimates
      start_date = Time.zone.now + Random.rand(1...500).days
      end_date = start_date + Random.rand(1..10).days
      request = TravelRequest.create!(creator: creator,
                                      event_requests_attributes: [event_requests_attributes(recurring_events: recurring_events)],
                                      estimates_attributes: estimates,
                                      start_date: start_date, end_date: end_date)
      request = generate_random_note(request, creator)
      generate_random_state_changes(request, status)
    end

    def generate_absence_request(creator:, status: "pending")
      start_date = Time.zone.now + Random.rand(-10...50).days
      hours_to_end = Random.rand(4..120)
      end_date = start_date + hours_to_end.hours
      hours_requested = [(hours_to_end % 24), 7.25].min + # partial day up to 7.25
                        (hours_to_end / 24).to_i * 7.25 # whole days
      request = AbsenceRequest.create!(creator: creator, start_date: start_date, end_date: end_date,
                                       absence_type: Request.absence_types.keys.sample,
                                       hours_requested: hours_requested)
      request = generate_random_note(request, creator)
      generate_random_state_changes(request, status)
    end

    private

      def event_requests_attributes(recurring_events:)
        event = recurring_events[Random.rand(0..recurring_events.count - 1)]
        {
          recurring_event_id: event.id,
          location: Faker::Address.city,
          url: "http://#{event.name.parameterize}_#{Faker::Address.city}.org",
          start_date: Time.zone.now + Random.rand(1...500).days
        }
      end

      def generate_random_recurring_events
        1.upto(Random.rand(20...100)) do
          name = Faker::Hacker.noun + Faker::Hacker.ingverb
          RecurringEvent.create(name: name.titleize, url: "http://#{name.parameterize}.org",
                                description: Faker::Hacker.say_something_smart)
        end
        RecurringEvent.all
      end

      def generate_random_state_changes(request, status)
        return if status == "pending"

        supervisor_approved = status == "approved"
        action = supervisor_approved ? "approve" : "deny"
        request.aasm.fire(action, agent: request.creator.supervisor)
        if request.is_a?(TravelRequest) && supervisor_approved
          request.aasm.fire(action, agent: request.creator.department.head)
          request.travel_category = Request.travel_categories.keys.sample
        elsif !supervisor_approved
          request = generate_random_note(request, request.creator.supervisor)
        end
        request.save
        request
      end

      def generate_random_estimates
        estimates = []
        1.upto(Random.rand(2...10)) do
          estimates << { amount: Random.rand(10...1000), cost_type: Estimate.cost_types.keys.sample, recurrence: Random.rand(1...5), description: Faker::Hacker.say_something_smart }
        end
        estimates
      end

      def generate_random_note(request, creator)
        Note.create!(request: request, creator: creator,
                     content: Faker::Hacker.say_something_smart)

        request
      end
    end
end
