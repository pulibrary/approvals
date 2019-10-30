# frozen_string_literal: true
class AbsenceRequestChangeSet < Reform::Form
  property :creator_id
  property :absence_type
  property :hours_requested
  property :start_date, populator: ->(options) { populate_date(field: "start_date", options: options) }
  property :end_date, populator: ->(options) { populate_date(field: "end_date", options: options) }
  property :start_time, default: Time.zone.parse("8:45 AM")
  property :end_time, default: Time.zone.parse("5:00 PM")
  collection :notes, form: NoteChangeSet, populator: NoteChangeSet::NotePopulator

  validates :absence_type, inclusion: { in: Request.absence_types.keys }
  validates :creator_id, :hours_requested, :start_date, :end_date, presence: true

  attr_reader :current_staff_profile

  def initialize(model, current_staff_profile: nil, **)
    super
    @current_staff_profile = current_staff_profile
  end

  delegate :vacation_balance, :personal_balance, :sick_balance, to: :creator

  def balance_title
    last_month = (Time.zone.today - 1.month).end_of_month
    "Balances as of #{last_month.strftime('%B %-d, %Y')}"
  end

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

  def hours_per_day(current_staff_profile)
    creator = model&.creator || current_staff_profile
    (creator.standard_hours_per_week || 40) / 5.0
  end

  def start_date_js
    lstart_date = start_date || Time.zone.today
    lstart_date.strftime("%m/%d/%Y")
  end

  def end_date_js
    lend_date = end_date || Time.zone.today
    lend_date.strftime("%m/%d/%Y")
  end

  def populate_date(field:, options:)
    data = options[:doc][field]
    return false if data.blank?

    date_format = if data.include?("/")
                    "%m/%d/%Y"
                  else
                    "%Y-%m-%d"
                  end
    send("#{field}=".to_sym, Date.strptime(data, date_format))
  end

  def supervisor(current_staff_profile)
    if model.creator
      model.creator.supervisor
    else
      current_staff_profile.supervisor
    end
  end

  private

    def creator
      model.creator || current_staff_profile
    end
end
