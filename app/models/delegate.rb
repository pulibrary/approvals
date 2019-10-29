# frozen_string_literal: true
class Delegate < ApplicationRecord
  belongs_to :delegate, class_name: "StaffProfile", foreign_key: "delegate_id"
  belongs_to :delegator, class_name: "StaffProfile", foreign_key: "delegator_id"
end
