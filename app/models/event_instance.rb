class EventInstance < ApplicationRecord
  belongs_to :event

  has_many :attendances
  # we model this as many-to-many to allow for future feature enhancements if
  # needed. Initial intention is only one event instance per request.
  has_many :requests, through: :attendances
end
