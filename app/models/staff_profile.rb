# frozen_string_literal: true
class StaffProfile < ApplicationRecord
  belongs_to :user, optional: false
  belongs_to :department, optional: false
  belongs_to :supervisor, class_name: "StaffProfile", optional: true
  belongs_to :location, optional: false

  attr_accessor :current_delegate

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

  def full_name
    "#{given_name} #{surname}"
  end

  def staff_list_json
    @values ||= StaffProfile.all.map do |u|
      "{ id: '#{u.id}', label: '#{u}' }"
    end.join(",")
    "[#{@values}]"
  end

  def department_head?
    Department.where(head_id: id).count.positive?
  end

  def supervisor?
    StaffProfile.where(supervisor: id).count.positive?
  end

  def supervisor_chain(agent: self, list: [])
    return list if agent.supervisor.blank?

    list << agent.supervisor
    supervisor_chain(agent: agent.supervisor, list: list)
  end

  def list_supervised(list:)
    supervised = StaffProfile.where(supervisor: self)
    return list if supervised.empty?
    list |= supervised
    supervised.each do |staff|
      list = staff.list_supervised(list: list)
    end
    list
  end

  def admin_assistants
    return [location.admin_assistant] if location&.admin_assistant
    department.admin_assistants
  end
end
