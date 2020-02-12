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

  has_many :notes, dependent: :destroy
  accepts_nested_attributes_for :notes

  has_many :estimates, dependent: :destroy
  accepts_nested_attributes_for :estimates

  has_many :state_changes, dependent: :destroy

  def self.where_contains_text(search_query:)
    # returning all which is the relation
    return all if search_query.blank?

    # search by id
    id_results = Request.where(id: search_query)
    return id_results if id_results.count.positive?

    # escapes the punctuation within the query
    query = connection.quote("%#{search_query}%")

    # ilike is a case insensitive like
    joins(:creator).left_joins(:notes).where("notes.content ilike #{query} or event_title ilike #{query} or staff_profiles.given_name ilike #{query} or staff_profiles.surname ilike #{query}").distinct
  end

  enum status: {
    pending: "pending",
    canceled: "canceled",
    changes_requested: "changes_requested",
    approved: "approved",
    denied: "denied",
    pending_cancelation: "pending_cancelation",
    recorded: "recorded"
  }

  enum participation: {
    presenter: "presenter",
    member: "member",
    committee_chair: "committee_chair",
    committee_member: "committee_member",
    other: "other",
    site_visit: "site_visit",
    training: "training",
    vendor_visit: "vendor_visit",
    donor_visit: "donor_visit",
    participant: "participant"
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

  def latest_state_change
    state_changes.order("created_at ASC").last
  end

  def ordered_state_changes(action: nil)
    ordered = state_changes.order("created_at ASC")
    return ordered unless action.present?
    ordered.select do |change|
      change.action == action
    end
  end

  def travel?
    false
  end

  private

    def raise_invalid_argument(property_name:)
      raise ActiveModel::UnknownAttributeError.new(self, property_name)
    end
end
