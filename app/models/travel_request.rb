# a single table inheritance class
#  - attributes are defined on Request
#  - behavior can be defined here
class TravelRequest < Request
  def to_s
    "#{creator}  #{event_requests.first.recurring_event.name}"
  end
end
