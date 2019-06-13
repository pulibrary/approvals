# frozen_string_literal: true
class AbsenceRequestChangeSet < Reform::Form
  property :creator_id
  property :absence_type
  property :start_date
  property :end_date
  property :start_time, default: Time.zone.parse("8:45 AM")
  property :end_time, default: Time.zone.parse("5:00 PM")
  collection :notes, form: NoteChangeSet, populator: NoteChangeSet::NotePopulator

  validates :absence_type, inclusion: { in: Request.absence_types.keys }
  validates :creator_id, presence: true

  def absence_type_options
    # turn key, value into label, key
    strings = model.class.absence_types.map do |key, value|
      "{label: '#{value.humanize}', value: '#{key}'}"
    end
    "[#{strings.join(',')}]"
  end

  def time_options
    clock = Time.zone.parse("12:00 AM")
    builder = "["
    96.times do
      builder += "{label: '#{format_time(clock)}', value: '#{format_time(clock)}'},"
      clock = clock.advance(minutes: 15)
    end
    builder + "]"
  end

  def format_time(time)
    time.strftime("%l:%M %p").strip
  end

  def holidays
    Holidays.list.to_json
  end

  def hours_per_day
    8
  end
end
