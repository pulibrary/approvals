# frozen_string_literal: true
class AbsenceRequestDecorator < RequestDecorator
  delegate :absence_type, :hours_requested, :vacation_balance, :creator, :can_modify_attributes?, to: :request
  delegate :full_name, :department, to: :creator
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
      "consulting" => "consulting leave",
      "jury_duty" => "jury duty leave",
      "death_in_family" => "death in the family leave"
    }
    title_map[absence_type]&.titleize
  end

  def event_title_brief
    "#{title} (#{hours_requested})"
  end

  def event_title
    "#{title} (#{event_dates})"
  end

  def event_dates
    "#{start_date.strftime(date_format)} to #{end_date.strftime(date_format)}"
  end

  def event_format
    ""
  end

  def review_path
    Rails.application.routes.url_helpers.review_absence_request_url(request)
  end

  def show_path
    Rails.application.routes.url_helpers.absence_request_url(request)
  end

  def review_details
    {
      "Type" => absence_type.titleize,
      "Dates Away" => event_dates,
      "Total absence time in hours" => hours_requested
    }
  end

  def next_supervisor
    return if creator.blank?
    creator.supervisor
  end
end
