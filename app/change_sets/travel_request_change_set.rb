# frozen_string_literal: true
class TravelRequestChangeSet < Reform::Form
  property :creator_id
  property :travel_category
  property :start_date
  property :end_date
  property :purpose
  property :participation

  collection :notes, form: NoteChangeSet, populator: NoteChangeSet::NotePopulator
  collection :event_requests, form: EventRequestChangeSet, populator: EventRequestChangeSet::EventRequestPopulator, prepopulator: EventRequestChangeSet::EventRequestPrepopulator
  collection :estimates, form: EstimateChangeSet, populator: EstimateChangeSet::EstimatePopulator

  validates :travel_category, inclusion: { in: Request.travel_categories.keys, allow_blank: true }
  validates :creator_id, presence: true
  validates :event_requests, presence: true
end
