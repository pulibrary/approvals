# This is a base class for TravelRequest and AbsenceRequest and is not intended
# to be created directly
class Request < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"

  has_many :event_requests
  # we model this as many-to-many to allow for future feature enhancements if
  # needed. Initial intention is only one event request per request.
  has_many :events, through: :event_requests
  accepts_nested_attributes_for :event_requests

  # use request_type as the single table inheritance flag
  self.inheritance_column = "request_type"
end
