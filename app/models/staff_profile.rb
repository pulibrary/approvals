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
      "{ id: '#{u.id}', label: '#{escape_single_quotes(u.to_s)}' }"
    end.join(",")
    "[#{@values}]"
  end

  def department_head?
    Department.where(head_id: id).count.positive?
  end

  def supervisor?
    StaffProfile.where(supervisor: id).count.positive?
  end

  def admin_assistant?
    AdminAssistantsDepartment.joins(:department).where(admin_assistants_departments: { admin_assistant_id: id }).count.positive?
  end

  def supervisor_chain(agent: self, list: [])
    return list if agent.supervisor.blank?

    list << agent.supervisor
    supervisor_chain(agent: agent.supervisor, list: list)
  end

  def list_supervised(list:)
    if admin_assistant?
      aa_departments = AdminAssistantsDepartment.joins(:department).where(admin_assistants_departments: { admin_assistant_id: id })
      aa_departments.each do |dep|
        list |= StaffProfile.where(department: dep.department_id)
      end
    end
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

  private

  def escape_single_quotes(string)
    string.gsub(/'/) { |x| "\\#{x}" }
  end
end
