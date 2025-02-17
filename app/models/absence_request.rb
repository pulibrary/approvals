# frozen_string_literal: true

# a single table inheritance class
#  - attributes are defined on Request
#  - behavior can be defined here
class AbsenceRequest < Request
  include AasmConfig

  def to_s
    "#{creator} Absence"
  end

  aasm column: "status" do
    # add in an additional state recorded which is only valid for an absence request
    state :recorded

    event :record do
      transitions from: :approved, to: :recorded
    end

    event :cancel do
      transitions from: %i[pending approved recorded], to: :canceled, guard: :only_creator
    end
  end

  ##########  Invalid Attributes ###########
  # Because we are using single table inheritance there are a number of fields in a Request
  # that are only valid for a travel request.
  # The methods below force an invalid attribute error if someone tries to access them

  # participation is not a valid property of a AbsenceRequest
  def participation=(*_args)
    raise_invalid_argument(property_name: :participation)
  end

  def participation
    raise_invalid_argument(property_name: :participation)
  end

  # purpose is not a valid property of a AbsenceRequest
  def purpose=(*_args)
    raise_invalid_argument(property_name: :purpose)
  end

  def purpose
    raise_invalid_argument(property_name: :purpose)
  end

  # estimates is not a valid property of a AbsenceRequest
  def estimates=(*_args)
    raise_invalid_argument(property_name: :estimates)
  end

  def estimates
    raise_invalid_argument(property_name: :estimates)
  end

  # event_requests is not a valid property of a AbsenceRequest
  def event_requests=(*_args)
    raise_invalid_argument(property_name: :event_requests)
  end

  def event_requests
    raise_invalid_argument(property_name: :event_requests)
  end

  # travel_category is not a valid property of a AbsenceRequest
  def travel_category=(*_args)
    raise_invalid_argument(property_name: :travel_category)
  end

  def travel_category
    raise_invalid_argument(property_name: :travel_category)
  end

  def can_modify_attributes?
    pending?
  end

  def can_record?(agent:)
    approved? && in_supervisor_chain(supervisor: creator, agent:)
  end
end
