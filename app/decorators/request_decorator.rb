# frozen_string_literal: true
class RequestDecorator
  delegate :created_at, :end_date, :id, :request_type, :start_date, :status, :to_model, :state_changes,
           to: :request
  attr_reader :request

  def initialize(request)
    @request = request
  end

  def latest_status
    "#{decorated_status} on #{date_of_status.strftime(date_format)}"
  end

  def status_icon
    icon_map = {
      "pending" => "lux-icon-clock",
      "approved" => "lux-icon-approved",
      "denied" => "lux-icon-denied",
      "changes_requested" => "lux-icon-alert",
      # TODO: these do not exist yet
      "canceled" => "lux-icon-alert",
      "recorded" => "lux-icon-file",
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

    def decorated_status
      if (status == "pending") && state_changes.count.positive?
        "Pending further approval"
      else
        status.humanize
      end
    end

    def date_of_status
      if state_changes.empty?
        created_at
      else
        state_changes.last.created_at
      end
    end
end
