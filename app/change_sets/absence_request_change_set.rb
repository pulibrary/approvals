# frozen_string_literal: true
class AbsenceRequestChangeSet < Reform::Form
  property :creator_id
  property :absence_type
  property :hours_requested
  property :start_date, populator: ->(options) { self.start_date = Date.strptime(options[:doc]["start_date"], "%m/%d/%Y") }
  property :end_date, populator: ->(options) { self.end_date = Date.strptime(options[:doc]["end_date"], "%m/%d/%Y") }
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

  def start_date_js
    return '' if start_date.blank?

    start_date.strftime("%m/%d/%Y")
  end

  def end_date_js
    return '' if start_date.blank?

    end_date.strftime("%m/%d/%Y")
  end
end
