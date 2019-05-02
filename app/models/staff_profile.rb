class StaffProfile < ApplicationRecord
  belongs_to :user, required: true
  belongs_to :department, required: true
  belongs_to :supervisor, class_name: "User", optional: true
end
