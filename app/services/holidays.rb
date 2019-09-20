# frozen_string_literal: true
class Holidays
  class << self
    def list(config_file: Rails.root.join("config", "holidays.yml"))
      @list ||= parse_list(config_file)
    end

    private

      def parse_list(config_file)
        yaml = YAML.safe_load(File.read(config_file))
        yaml.map { |date_str| Date.parse(date_str) }
      end
  end
end
