# frozen_string_literal: true
class StaffProfile < ApplicationRecord
  belongs_to :user, required: true
  belongs_to :department, required: true
  belongs_to :supervisor, class_name: "StaffProfile", optional: true

  def to_s
    "#{surname}, #{given_name} (#{user.uid})"
  end

  def department_head?
    Department.where(head_id: id).count.positive?
  end
end
