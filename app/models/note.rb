# frozen_string_literal: true
class Note < ApplicationRecord
  belongs_to :request
  belongs_to :creator, class_name: "StaffProfile", foreign_key: "creator_id"

  default_scope { order("created_at ASC") }
end
