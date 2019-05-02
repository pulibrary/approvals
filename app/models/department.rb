class Department < ApplicationRecord
  belongs_to :head, class_name: "StaffProfile", optional: true
  belongs_to :admin_assistant, class_name: "StaffProfile", optional: true

  validates :name, presence: true

  def to_s
    name
  end
end
