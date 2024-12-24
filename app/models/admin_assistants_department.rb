# frozen_string_literal: true

class AdminAssistantsDepartment < ApplicationRecord
  belongs_to :department
  belongs_to :admin_assistant, class_name: "StaffProfile"
end
