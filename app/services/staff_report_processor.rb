# frozen_string_literal: true
require "csv"

class StaffReportProcessor
  class << self
    LIBRARY_DEAN_UID = "ajarvis"

    def process(data:, ldap_service_class: Ldap)
      manager_hash = {}
      csv = CSV.new(data, col_sep: "\t", headers: true)
      csv.each do |row|
        manager_hash = process_staff_entry(staff_entry: row, manager_hash: manager_hash, ldap_service_class: ldap_service_class)
      end
      connect_staff_to_managers(manager_hash: manager_hash)
      connect_managers_to_department(manager_hash: manager_hash)
      process_department_overrides
      set_vacant_supervisors_to_department_head
    end

    private

    def process_staff_entry(staff_entry:, manager_hash:, ldap_service_class:)
      net_id = staff_entry["Net ID"]
      user = create_user(net_id: net_id)
      department = create_department(name: staff_entry["Department Name"], number: staff_entry["Department Number"])
      create_staff_profile(user: user, department: department, staff_entry: staff_entry, ldap_service_class: ldap_service_class)
      manager_net_id = staff_entry["Manager Net ID"]
      manager_hash[manager_net_id] = Array(manager_hash[manager_net_id]) << net_id
      manager_hash
    end

    def create_user(net_id:)
      user = User.where(uid: net_id)
      return user[0] unless user.empty?

      User.create(uid: net_id, provider: "cas")
    end

    def create_department(name:, number:)
      department = Department.where(number: number)
      return department[0] unless department.empty?

      Department.create(name: name, number: number)
    end

    def create_staff_profile(user:, department:, staff_entry:, ldap_service_class:)
      biweekly = staff_entry["Paid"] == "Biw"
      given_name = "#{staff_entry['First Name']} #{staff_entry['Middle Name']}".strip
      surname = staff_entry["Last Name"]
      email = "#{user.uid}@princeton.edu"
      location = find_location(net_id: user.uid, ldap_service_class: ldap_service_class)

      staff_profile = StaffProfile.where(user_id: user.id).first
      staff_profile ||= StaffProfile.new
      staff_profile.update_attributes(user: user, department: department, biweekly: biweekly,
                                      given_name: given_name, surname: surname, email: email, location: location)
      staff_profile.save
    end

    def find_location(net_id:, ldap_service_class:)
      ldap_info = ldap_service_class.find_by_netid(net_id)
      building = if ldap_info[:address].blank?
                   Rails.logger.warn("Netid without address: #{net_id}")
                   "Blank"
                 else
                   ldap_info[:address].split("$").first
                 end

      location = Location.where(building: building)
      if location.blank?
        Rails.logger.warn("No location found for #{building}.  Creating a new one!")
        location = [Location.create!(building: building)]
      end
      location.first
    end

    def connect_staff_to_managers(manager_hash:)
      manager_hash.each_key do |manager_net_id|
        manager_profile = StaffProfile.find_by(uid: manager_net_id)
        next if manager_profile.blank?
        manager_hash[manager_net_id].each do |report_net_id|
          report_profile = StaffProfile.find_by(uid: report_net_id)
          report_profile.supervisor = manager_profile
          report_profile.save
        end
      end
    end

    def process_department_overrides
      overrides = YAML.safe_load(File.read("config/departments.yml"))
      overrides.each do |department_no, attributes|
        department = Department.find_by(number: department_no)
        next if department.blank?

        department_head = StaffProfile.find_by(uid: attributes["head_uid"])
        department.head = department_head
        department.save
      end
    end

    def connect_managers_to_department(manager_hash:)
      library_dean = StaffProfile.find_by(uid: LIBRARY_DEAN_UID)
      manager_hash.each_key do |manager_net_id|
        manager_profile = StaffProfile.find_by(uid: manager_net_id)
        next if manager_profile.blank?
        if manager_profile.supervisor == library_dean
          manager_profile.department.head = manager_profile
          manager_profile.department.save
        end
      end
    end

    def set_vacant_supervisors_to_department_head
      library_dean = StaffProfile.find_by(uid: LIBRARY_DEAN_UID)
      StaffProfile.where.not(id: library_dean).where(supervisor: nil).each do |profile|
        profile.supervisor = profile.department.head
        profile.save
      end
    end
  end
end
