class AbsenceRequestDecorator
  delegate :absence_type, :end_date, :id, :request_type, :start_date, :status, :to_model, to: :absence_request
  attr_reader :absence_request

  def initialize(absence_request)
    @absence_request = absence_request
  end

  def absence_type_icon
    icon_map = {
      "vacation" => "lux-icon-vacation",
      "sick" => "lux-icon-hospital",
      "personal" => "lux-icon-relax",
      "research_days" => "lux-icon-file",
      "work_from_home" => "lux-icon-clock",
      "consulting" => "lux-icon-clock",
      "jury_duty" => "lux-icon-scales",
      "death_in_family" => "lux-icon-flower"
    }
    icon_map[absence_type]
  end

  def status_icon
    icon_map = {
      "pending" => "lux-icon-clock",
      "approved" => "lux-icon-approved",
      "denied" => "lux-icon-denied",
      "changes_requested" => "lux-icon-alert",
      # TODO: these do not exist yet
      "canceled" => "lux-icon-alert",
      "reported" => "lux-icon-file",
      "pending_cancelation" => "lux-icon-flower"
    }
    icon_map[status]
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

  def formatted_start_date
    start_date.strftime(date_format)
  end

  def formatted_end_date
    end_date.strftime(date_format)
  end

  private

    def date_format
      "%b %-d, %Y"
    end
end
