# This is a base class for TravelRequest and AbsenceRequest and is not intended
# to be created directly
class Request < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"

  has_many :attendances
  # we model this as many-to-many to allow for future feature enhancements if
  # needed. Initial intention is only one event instance per request.
  has_many :event_instances, through: :attendances
  accepts_nested_attributes_for :event_instances

  # use request_type as the single table inheritance flag
  self.inheritance_column = "request_type"
end
