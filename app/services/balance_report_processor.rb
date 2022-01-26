# frozen_string_literal: true
require "csv"

class BalanceReportProcessor
  class << self
    def process(data:)
      csv = CSV.new(data, col_sep: "\t", headers: true)
      errors = { unknown: [] }
      csv.each do |row|
        next if row.blank?
        errors = process_balance_entry(balance_entry: row, errors: errors)
      end
      errors
    end

    private

    def process_balance_entry(balance_entry:, errors:)
      net_id = balance_entry["Net ID"]
      return errors if net_id.blank?

      profile = StaffProfile.find_by(uid: net_id)
      if profile.blank?
        errors[:unknown] << net_id
        return errors
      end
      profile.vacation_balance = balance_entry["Vac Bal"]
      profile.sick_balance = balance_entry["Sick Bal"]
      profile.personal_balance = balance_entry["Per Bal"]
      profile.biweekly = balance_entry["# Pays"] == "26" # 26 pays per year means biweekly
      profile.standard_hours_per_week = balance_entry["Standard Hours"]
      profile.save

      errors
    end
  end
end
