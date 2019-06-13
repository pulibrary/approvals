# frozen_string_literal: true
class RequestDecorator
  delegate :end_date, :id, :request_type, :start_date, :status, :to_model,
           to: :request
  attr_reader :request

  def initialize(request)
    @request = request
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
