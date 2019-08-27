# frozen_string_literal: true
class StaffProfile < ApplicationRecord
  belongs_to :user, required: true
  belongs_to :department, required: true
  belongs_to :supervisor, class_name: "StaffProfile", optional: true

  delegate :uid, to: :user

  class << self
    def find_by(*args)
      return super unless args.first.keys.include?(:uid)

      # uid is not part of the staff_profile, but it is part of the attached user
      find_by_uid(*args)
    end

    private

      def find_by_uid(*args)
        user = User.find_by(*args)
        return if user.blank?

        user.staff_profile
      end
    end

  def to_s
    "#{surname}, #{given_name} (#{user.uid})"
  end

  def department_head?
    Department.where(head_id: id).count.positive?
  end
end
