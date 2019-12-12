# frozen_string_literal: true
class StateChange < ApplicationRecord
  belongs_to :agent, class_name: "StaffProfile", required: true
  belongs_to :request, required: true
  belongs_to :delegate, class_name: "StaffProfile", required: false

  accepts_nested_attributes_for :request

  def title
    date = created_at.strftime(Rails.configuration.short_date_format)
    if delegate
      "#{action.titleize} by #{delegate.full_name} on behalf of #{agent.full_name} on #{date}"
    else
      "#{action.titleize} by #{agent.full_name} on #{date}"
    end
  end
end
