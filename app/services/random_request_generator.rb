class RandomRequestGenerator
  class << self
    def generate_travel_request(creator:, status: "pending")
      estimates = generate_random_estimates
      start_date = Time.zone.now + Random.rand(1...500).days
      end_date = start_date + Random.rand(1..10).days
      request = TravelRequest.create!(creator: creator,
                                      event_requests_attributes: [{ recurring_event_id: RecurringEvent.first.id }],
                                      estimates_attributes: estimates, status: status,
                                      start_date: start_date, end_date: end_date)
      request = generate_random_state_changes(request)
      generate_random_note(request, creator)
    end

    def generate_absence_request(creator:, status: "pending")
      start_date = Time.zone.now + Random.rand(-10...50).days
      end_date = start_date + Random.rand(4..40).hours
      request = AbsenceRequest.create!(creator: creator, start_date: start_date, end_date: end_date,
                                       absence_type: Request.absence_types.keys[Random.rand(0..7)], status: status)
      request = generate_random_state_changes(request)
      generate_random_note(request, creator)
    end

    private

      def generate_random_state_changes(request)
        return request if request.pending?

        supervisor_approved = request.approved?
        action = supervisor_approved ? "approved" : "denied"
        StateChange.create!(request: request, approver: request.creator.supervisor, action: action)
        if request.is_a?(TravelRequest) && supervisor_approved
          StateChange.create!(request: request, approver: request.creator.department.head, action: action)
        elsif !supervisor_approved
          request = generate_random_note(request, request.creator.supervisor)
        end
        request
      end

      def generate_random_estimates
        estimates = []
        1.upto(Random.rand(2...10)) do
          estimates << { amount: Random.rand(10...1000), cost_type: Estimate.cost_types.keys[Random.rand(0..10)], recurrence: Random.rand(1...5) }
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
