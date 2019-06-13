# frozen_string_literal: true
# This is a base class for TravelRequest and AbsenceRequest and is not intended
# to be created directly
class Request < ApplicationRecord
  belongs_to :creator, class_name: "StaffProfile", foreign_key: "creator_id"

  has_many :event_requests
  # we model this as many-to-many to allow for future feature enhancements if
  # needed. Initial intention is only one event request per request.
  has_many :recurring_events, through: :event_requests
  accepts_nested_attributes_for :event_requests

  has_many :notes
  accepts_nested_attributes_for :notes

  has_many :estimates
  accepts_nested_attributes_for :estimates

  has_many :state_changes

  def self.where_notes_contain(search_query:)
    # returning all which is the relation
    return all if search_query.blank?

    joins(:notes).where("notes.content like '%#{search_query}'")
  end

  enum status: {
    pending: "pending",
    canceled: "canceled",
    changes_requested: "changes_requested",
    approved: "approved",
    denied: "denied",
    pending_cancelation: "pending_cancelation",
    reported: "reported"
  }

  enum participation: {
    presenter: "presenter",
    member: "member",
    committee_chair: "committee_chair",
    committee_member: "committee_member",
    other: "other",
    site_visit: "site_visit",
    training: "training"
  }

  enum travel_category: {
    business: "business",
    professional_development: "professional_development",
    discretionary: "discretionary"
  }

  enum absence_type: {
    vacation: "vacation",
    sick: "sick",
    personal: "personal",
    research_days: "research_days",
    work_from_home: "work_from_home",
    consulting: "consulting",
    jury_duty: "jury_duty",
    death_in_family: "death_in_family"
  }

  # use request_type as the single table inheritance flag
  self.inheritance_column = "request_type"
end
