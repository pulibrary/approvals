# frozen_string_literal: true
# a single table inheritance class
#  - attributes are defined on Request
#  - behavior can be defined here
class TravelRequest < Request
  include AasmConfig

  attr_accessor :travel_dates, :event_dates # to allow for error messages to be attached to the form fields

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
      transitions from: :pending, to: :approved, guard: :only_department_head
      transitions from: :pending, to: :pending, guard: :only_supervisor
    end

    # Redefine the cancel event to allow cancelation from changes_requested
    event :cancel do
      transitions from: [:pending, :approved, :changes_requested], to: :canceled, guard: :only_creator
    end
  end

  def update_recurring_events!(target_recurring_event:)
    event_requests.each do |er|
      er.recurring_event = target_recurring_event
      er.update_event_title
      er.save!
    end
  end

  def estimated_total
    total = 0
    estimates.each do |estimate|
      total += estimate.amount * estimate.recurrence
    end
    total
  end

  ##########  Invalid Attributes ###########
  # Because we are using single table inheritance there are a number of fields in a Request
  # that are only valid for a absence request.
  # The methods below force an invalid attribute error if someone tries to access them

  # absence_type is not a valid property of a TravelRequest
  def absence_type=(*_args)
    raise_invalid_argument(property_name: :absence_type)
  end

  def absence_type
    raise_invalid_argument(property_name: :absence_type)
  end

  # hours_requested is not a valid property of a TravelRequest
  def hours_requested=(*_args)
    raise_invalid_argument(property_name: :hours_requested)
  end

  def hours_requested
    raise_invalid_argument(property_name: :hours_requested)
  end

  # end_time is not a valid property of a TravelRequest
  def end_time=(*_args)
    raise_invalid_argument(property_name: :end_time)
  end

  def end_time
    raise_invalid_argument(property_name: :end_time)
  end

  # start_time is not a valid property of a TravelRequest
  def start_time=(*_args)
    raise_invalid_argument(property_name: :start_time)
  end

  def start_time
    raise_invalid_argument(property_name: :start_time)
  end

  def can_modify_attributes?
    changes_requested? || (pending? && (state_changes.empty? || state_changes.last.pending?))
  end

  def travel?
    true
  end
end
