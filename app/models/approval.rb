class Approval < ApplicationRecord
  belongs_to :approver, class_name: "StaffProfile", required: true
  belongs_to :request, required: true

  accepts_nested_attributes_for :request
end
