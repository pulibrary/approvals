# frozen_string_literal: true

class RequestChangeSet < Reform::Form
  property :creator_id
  property :start_date
  property :end_date

  collection :notes, form: NoteChangeSet, populator: NoteChangeSet::NotePopulator

  validates :creator_id, presence: true

  delegate :full_name, to: :creator
  delegate :latest_status, :status_color, :status_icon,
           :event_title, :notes_and_changes, :absent_staff,
           :formatted_full_start_date, :formatted_full_end_date,
           :estimate_fields_json, :estimates_json,
           :event_attendees, :can_modify_attributes?,
           to: :decorated_model

  attr_reader :current_staff_profile

  def initialize(model, current_staff_profile: nil, **)
    super
    @current_staff_profile = current_staff_profile
  end
end
