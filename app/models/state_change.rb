# frozen_string_literal: true
class StateChange < ApplicationRecord
  belongs_to :agent, class_name: "StaffProfile", required: true
  belongs_to :request, required: true
  belongs_to :delegate, class_name: "StaffProfile", required: false

  accepts_nested_attributes_for :request

  enum action: {
    pending: "pending",
    canceled: "canceled",
    changes_requested: "changes_requested",
    approved: "approved",
    denied: "denied",
    pending_cancelation: "pending_cancelation",
    recorded: "recorded"
  }

  def title
    "#{action.titleize} by #{actor_and_date}"
  end

  def actor_and_date
    date = created_at.strftime(Rails.configuration.short_date_format)
    if delegate
      "#{delegate.full_name} on behalf of #{agent.full_name} on #{date}"
    else
      "#{agent.full_name} on #{date}"
    end
  end
end
