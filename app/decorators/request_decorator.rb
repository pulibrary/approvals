# frozen_string_literal: true
class RequestDecorator
  include Rails.application.routes.url_helpers

  delegate :created_at, :end_date, :id, :request_type, :start_date, :status, :to_model, :state_changes,
           :creator, :creator_id, :notes, :latest_state_change, :ordered_state_changes, :updated_at,
           :approved?, :canceled?, :recorded?, to: :request
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

  def status_icon(status: self.status)
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

  def formatted_created_at
    created_at.strftime(date_format)
  end

  def formatted_updated_at
    updated_at.strftime(date_format)
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

  def notes_and_changes
    both = notes.to_a
    delegate_note = both.shift if created_by_delegate
    both.concat(state_changes.to_a)
    both = both.sort_by(&:created_at)
    json = both.map { |item| item_json(item) }
    created_state(json: json, delegate_note: delegate_note)
  end

  def last_supervisor_to_approve
    last_state_change = request.latest_state_change
    last_state_change.agent if last_state_change && (last_state_change.action == "approved")
  end

  def latest_state_change_title
    title_for_state(state: @request.latest_state_change)
  end

  def previous_state_change_title
    title_for_state(state: previous_state, phrase: "was")
  end

  def previous_state
    count = ordered_state_changes.count
    return unless count >= 2
    ordered_state_changes[count - 2]
  end

  def deny_or_change_details
    details = review_details
    details = details.merge("Note" => notes.last.content) if notes.last.present?
    details
  end

  private

    def title_for_state(state:, phrase: "has been")
      return "" if state.blank?
      if state.pending_cancelation?
        "Cancelation #{phrase} requested by #{state.actor_and_date}."
      else
        "It #{phrase} #{state.title}."
      end
    end

    def date_format
      "%m/%d/%Y"
    end

    def full_date_format
      "%B %-d, %Y"
    end

    def decorated_status
      if (status == "pending") && state_changes.count.positive?
        "Pending further review"
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

    def item_json(item)
      if item.is_a? Note
        {
          title: "#{item.creator.full_name} on #{item.created_at.strftime(date_format)}",
          content: item.content,
          icon: "note"
        }
      else
        {
          title: item.title,
          content: nil,
          icon: status_icon(status: item.action)
        }
      end
    end

    def created_state(json:, delegate_note:)
      title = if delegate_note.present?
                "Created by #{delegate_note.creator.full_name} on behalf of #{creator.full_name} on #{created_at.strftime(date_format)}"
              else
                "Created by #{creator.full_name} on #{created_at.strftime(date_format)}"
              end
      json.prepend(title: title, content: nil, icon: "add")
    end

    def created_by_delegate
      first_note = notes.first
      first_note.present? && first_note.creator_id != creator_id && first_note.content.start_with?("This request was created by")
    end
end
