# frozen_string_literal: true
class Delegate < ApplicationRecord
  belongs_to :delegate, class_name: "StaffProfile"
  belongs_to :delegator, class_name: "StaffProfile"
  validates :delegator, uniqueness: { scope: :delegate }
end
