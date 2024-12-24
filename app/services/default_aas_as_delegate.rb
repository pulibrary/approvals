# frozen_string_literal: true

class DefaultAasAsDelegate
  class << self
    def run(profiles: StaffProfile.all)
      profiles.each do |profile|
        update_profile(profile)
      end
    end

    private

      def update_profile(profile)
        aas = profile.admin_assistants
        return if aas.blank?

        aas.each do |admin_assistant|
          next if admin_assistant == profile

          Delegate.create(delegate: admin_assistant, delegator: profile)
        end
      end
  end
end
