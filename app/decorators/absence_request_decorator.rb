# frozen_string_literal: true
class AbsenceRequestDecorator < RequestDecorator
  delegate :absence_type, :hours_requested, :vacation_balance, :creator, to: :request
  delegate :full_name, to: :creator
  attr_reader :absence_request

  def initialize(absence_request)
    super(absence_request)
    @request = absence_request
  end

  def absence_type_icon
    icon_map = {
      "vacation" => "lux-icon-vacation",
      "sick" => "lux-icon-hospital",
      "personal" => "lux-icon-relax",
      "research_days" => "lux-icon-research",
      "work_from_home" => "lux-icon-user-home",
      "consulting" => "lux-icon-consulting",
      "jury_duty" => "lux-icon-scales",
      "death_in_family" => "lux-icon-flower"
    }
    icon_map[absence_type]
  end

  def title
    title_map = {
      "vacation" => "vacation",
      "sick" => "sick leave",
      "personal" => "personal days",
      "research_days" => "research days",
      "work_from_home" => "work from home time",
      "consulting" => "consulting leave",
      "jury_duty" => "jury duty leave",
      "death_in_family" => "death in the family leave"
    }
    title_map[absence_type].titleize
  end

  def event_title_brief
    title
  end

  def event_title
    "#{title} (#{start_date.strftime(date_format)} to #{end_date.strftime(date_format)})"
  end
end
