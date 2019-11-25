# frozen_string_literal: true
class Department < ApplicationRecord
  belongs_to :head, class_name: "StaffProfile", optional: true
  has_and_belongs_to_many :admin_assistants, class_name: "StaffProfile", join_table: :admin_assistants_departments, association_foreign_key: :admin_assistant_id

  validates :name, presence: true

  def to_s
    name
  end
end
