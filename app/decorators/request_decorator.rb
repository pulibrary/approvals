# frozen_string_literal: true
class RequestDecorator
  delegate :created_at, :end_date, :id, :request_type, :start_date, :status, :to_model, :state_changes,
           :creator, :notes, to: :request
  attr_reader :request

  def initialize(request)
    @request = request
  end

  def latest_status
    decorated_status.to_s
  end

  def latest_status_date
    "Updated on #{date_of_status.strftime(date_format)}"
  end

  def status_color
    color_map = {
      "pending" => "yellow",
      "approved" => "green",
      "denied" => "red",
      "changes_requested" => "yellow",
      "canceled" => "gray",
      "recorded" => "green",
      "pending_cancelation" => "yellow"
    }
    color_map[status]
  end

  def status_icon
    icon_map = {
      "pending" => "clock",
      "approved" => "approved",
      "denied" => "denied",
      "changes_requested" => "refresh",
      "canceled" => "alert",
      "recorded" => "reported",
      "pending_cancelation" => "remove"
    }
    icon_map[status]
  end

  def formatted_start_date
    start_date.strftime(date_format)
  end

  def formatted_end_date
    end_date.strftime(date_format)
  end

  def formatted_full_start_date
    start_date.strftime(full_date_format)
  end

  def formatted_full_end_date
    end_date.strftime(full_date_format)
  end

  def absent_staff
    @absent_staff ||= AbsentStaff.list(start_date: start_date, end_date: end_date, supervisor: creator.supervisor).uniq - [creator]
    @absent_staff << "No team members absent" if @absent_staff.empty?
    @absent_staff
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
      if item.is_a? Note
        content = item.content
        icon = "note"
      else
        icon = item.request.status
      end
      {
        title: title,
        content: content,
        icon: icon
      }
    end
  end

  private

    def date_format
      "%b %-d, %Y"
    end

    def full_date_format
      "%B %-d, %Y"
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
        "#{item.creator.full_name} on #{item.created_at.strftime(date_format)}"
      else
        "#{item.action.titleize} by #{item.agent.full_name} on #{item.created_at.strftime(date_format)}"
      end
    end
end
