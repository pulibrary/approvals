# frozen_string_literal: true
class RequestDecorator
  delegate :created_at, :end_date, :id, :request_type, :start_date, :status, :to_model, :state_changes,
           :creator, :notes, to: :request
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
      "changes_requested" => "lux-icon-refresh",
      "canceled" => "lux-icon-alert",
      "recorded" => "lux-icon-reported",
      "pending_cancelation" => "lux-icon-remove"
    }
    icon_map[status]
  end

  def formatted_start_date
    start_date.strftime(date_format)
  end

  def formatted_end_date
    end_date.strftime(date_format)
  end

  def absent_staff
    AbsentStaff.list(start_date: start_date, end_date: end_date, supervisor: creator.supervisor).uniq - [creator]
  end

  def attendance
    case status
    when "denied"
      "will not "
    when "approved"
      "will "
    when "canceled"
      "does not want to "
    else
      "wants to "
    end + attendance_verb
  end

  def requestor_status
    "#{creator.given_name} #{attendance} #{event_title}"
  end

  def notes_and_changes
    both = notes.to_a
    both.concat(state_changes.to_a)
    both = both.sort_by(&:created_at)
    both.map do |item|
      title = title_of_item(item)
      content = item.content if item.is_a? Note
      {
        title: title,
        content: content
      }
    end
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

    def title_of_item(item)
      if item.is_a? Note
        "Notes from #{item.creator.full_name}"
      else
        "#{item.action.titleize} by #{item.approver.full_name} on #{item.created_at.strftime(date_format)}"
      end
    end
end
