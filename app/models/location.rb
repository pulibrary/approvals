# frozen_string_literal: true

class Location < ApplicationRecord
  belongs_to :admin_assistant, class_name: "StaffProfile", optional: true
end
