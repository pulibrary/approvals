# frozen_string_literal: true

class LocationLoader
  class << self
    def load(config_file: Rails.root.join("config", "building_locations.yml"))
      yaml = YAML.safe_load(File.read(config_file))
      yaml.each do |building_opts|
        location = Location.where(building: building_opts["building"]).first
        location ||= Location.new
        location.update(clean_building_options(building_opts))
        location.save!
      end
    end

    private

      def clean_building_options(building_opts)
        if building_opts["admin_assistant"].present?
          aa_netid = building_opts.delete("admin_assistant")
          aa = StaffProfile.find_by(uid: aa_netid)
          building_opts[:admin_assistant_id] = aa.id if aa.present?
        end
        building_opts
      end
  end
end
