# frozen_string_literal: true
class Department < ApplicationRecord
  belongs_to :head, class_name: "StaffProfile", optional: true
  has_many :admin_assistants_departments, dependent: :delete_all
  has_many :admin_assistants, through: :admin_assistants_departments

  validates :name, presence: true

  def to_s
    name
  end
end
