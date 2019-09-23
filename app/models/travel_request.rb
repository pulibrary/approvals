# frozen_string_literal: true
# a single table inheritance class
#  - attributes are defined on Request
#  - behavior can be defined here
class TravelRequest < Request
  include AasmConfig

  def to_s
    "#{creator}  #{event_requests.first.recurring_event.name}"
  end

  aasm column: "status" do
    # add in additional state, changes_requested, which is only valid for a travel request
    state :changes_requested
    event :change_request do
      transitions from: :pending, to: :changes_requested, guard: :only_supervisor
    end

    event :fix_requested_changes do
      transitions from: :changes_requested, to: :pending
    end

    # Redefined the approve event to allow only department heads the ability to make the final approval
    event :approve do
      transitions from: :approved, to: :approved
      transitions from: :pending, to: :approved, guard: :only_department_head
      transitions from: :pending, to: :pending, guard: :only_supervisor
    end

    # Redefine the cancel event to allow cancelation from changes_requested
    event :cancel do
      transitions from: [:pending, :approved, :changes_requested], to: :canceled, guard: :only_creator
    end
  end
end
