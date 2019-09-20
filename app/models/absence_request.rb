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
    # add in an additional states pending_cancelation & recorded which are only valid for an absence request
    state :pending_cancelation
    state :recorded

    event :record do
      transitions from: :approved, to: :recorded
    end

    event :pending_cancel do
      transitions from: :recorded, to: :pending_cancelation
    end
  end
end
