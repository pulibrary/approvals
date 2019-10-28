# frozen_string_literal: true
class StateChange < ApplicationRecord
  belongs_to :agent, class_name: "StaffProfile", required: true
  belongs_to :request, required: true
  belongs_to :delegate, class_name: "StaffProfile", required: false

  accepts_nested_attributes_for :request
end
