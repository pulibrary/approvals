# frozen_string_literal: true
class StateChange < ApplicationRecord
  belongs_to :approver, class_name: "StaffProfile", required: true
  belongs_to :request, required: true
  before_save :calculate_new_status

  accepts_nested_attributes_for :request

  private

    def calculate_new_status
      request.status = new_status
      request.save
    end

    def new_status
      if (request.status == "recorded") && (action == "canceled")
        "pending_cancelation"
      elsif request.is_a?(TravelRequest) && (action == "approved") && !approver.department_head?
        "pending"
      else
        action
      end
    end
end
