# frozen_string_literal: true
class AbsenceRequestChangeSet < RequestChangeSet
  property :absence_type
  property :hours_requested
  property :start_date, populator: ->(options) { populate_date(field: "start_date", options: options) }
  property :end_date, populator: ->(options) { populate_date(field: "end_date", options: options) }
  property :start_time, default: Time.zone.parse("8:45 AM")
  property :end_time, default: Time.zone.parse("5:00 PM")

  validates :absence_type, inclusion: { in: Request.absence_types.keys }
  validates :hours_requested, :start_date, :end_date, presence: true

  delegate :vacation_balance, :personal_balance, :sick_balance, to: :creator
  delegate :absence_type_icon,
           to: :decorated_model

  def balance_title
    "Balances as of the end of your last pay period"
  end

  def absence_type_options
    # turn key, value into label, key
    model.class.absence_types.map do |key, value|
      { label: value.humanize, value: key }
    end
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

  def supervisor
    if model.creator
      model.creator.supervisor
    else
      current_staff_profile.supervisor
    end
  end

  def creator
    model.creator || current_staff_profile
  end

  private

  def decorated_model
    @decorated_model ||= AbsenceRequestDecorator.new(model)
  end
end
