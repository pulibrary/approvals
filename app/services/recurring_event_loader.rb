# frozen_string_literal: true

class RecurringEventLoader
  class << self
    def load(config_file: Rails.root.join("config", "recurring_events.yml"))
      yaml = YAML.safe_load(File.read(config_file))
      yaml.each do |name|
        event = RecurringEvent.where(name:).first
        event ||= RecurringEvent.new(name:)
        event.save!
      end
    end
  end
end
