# frozen_string_literal: true

require "csv"

class StaffReportProcessor
  class << self
    LIBRARY_DEAN_UID = "ajarvis"

    def process(data:, ldap_service_class: Ldap, department_config: File.read("config/departments.yml"))
      manager_hash = {}
      new_profiles = []
      csv = CSV.new(data, col_sep: "\t", headers: true)
      csv.each do |row|
        manager_hash = process_staff_entry(staff_entry: row, manager_hash:,
                                           ldap_service_class:, new_profiles:)
      end
      @library_dean = StaffProfile.find_by(uid: LIBRARY_DEAN_UID)
      connect_staff_to_managers(manager_hash:)
      connect_managers_to_department(manager_hash:)
      process_department_config(department_config:)
      set_vacant_supervisors_to_department_head
      DefaultAasAsDelegate.run(profiles: new_profiles)
    end

    private

      def process_staff_entry(staff_entry:, manager_hash:, ldap_service_class:, new_profiles:)
        net_id = staff_entry["Net ID"]
        user = create_user(net_id:)
        department = create_department(name: staff_entry["Department Name"], number: staff_entry["Department Number"])
        create_staff_profile(user:, department:, staff_entry:,
                             ldap_service_class:, new_profiles:)
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
        department = Department.where(number:)
        unless department.empty?
          department[0].name = name
          department[0].save
          return department[0]
        end

        Department.create(name:, number:)
      end

      def create_staff_profile(user:, department:, staff_entry:, ldap_service_class:, new_profiles:)
        biweekly = staff_entry["Paid"] == "Biw"
        given_name = "#{staff_entry['First Name']} #{staff_entry['Middle Name']}".strip
        surname = staff_entry["Last Name"]
        email = "#{user.uid}@princeton.edu"
        location = find_location(net_id: user.uid, ldap_service_class:)

        staff_profile = StaffProfile.where(user_id: user.id).first
        profile_is_new = staff_profile.blank?
        staff_profile ||= StaffProfile.new
        staff_profile.update(user:, department:, biweekly:,
                             given_name:, surname:, email:, location:)
        staff_profile.save
        new_profiles << staff_profile if profile_is_new
      end

      def find_location(net_id:, ldap_service_class:)
        ldap_info = ldap_service_class.find_by_netid(net_id)
        building = if ldap_info[:address].blank?
                     Rails.logger.warn("Netid without address: #{net_id}")
                     "Blank"
                   else
                     ldap_info[:address].split("$").first
                   end

        location = Location.where(building:)
        if location.blank?
          Rails.logger.warn("No location found for #{building}.  Creating a new one!")
          location = [Location.create!(building:)]
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

      def process_department_config(department_config:)
        overrides = YAML.safe_load(department_config)
        overrides.each do |department_no, attributes|
          department = Department.find_by(number: department_no)
          next if department.blank?

          department = set_department_head(department:, head_uid: attributes["head_uid"])
          department = set_admin_assistants(department:, admin_assistants: attributes["admin_assistant"])
          department.save
        end
      end

      def set_department_head(department:, head_uid:)
        department_head = StaffProfile.find_by(uid: head_uid)
        return department if department_head.blank?

        department.head = department_head
        if @library_dean != department_head
          department_head.supervisor = @library_dean
          department_head.save
        end
        department
      end

      def set_admin_assistants(department:, admin_assistants:)
        # Clear out old admin_assistants based on earlier configs
        department.admin_assistants = []
        admin_assistants.each do |net_id|
          aa = StaffProfile.find_by(uid: net_id)
          department.admin_assistants << aa if aa.present?
        end
        department.admin_assistants = department.admin_assistants.uniq
        department
      end

      def connect_managers_to_department(manager_hash:)
        manager_hash.each_key do |manager_net_id|
          manager_profile = StaffProfile.find_by(uid: manager_net_id)
          next if manager_profile.blank?

          if manager_profile.supervisor == @library_dean
            manager_profile.department.head = manager_profile
            manager_profile.department.save
          end
        end
      end

      def set_vacant_supervisors_to_department_head
        StaffProfile.where.not(id: @library_dean).where(supervisor: nil).each do |profile|
          profile.supervisor = profile.department.head
          profile.save
        end
      end
  end
end
