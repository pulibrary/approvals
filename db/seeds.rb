# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# lodaing locations from default configuration
LocationLoader.load

file = File.open(Rails.application.config.staff_report_location, encoding: "UTF-16")
report = file.read
begin
  StaffReportProcessor.process(data: report)
rescue NoMethodError
  raise "Could not seed the database -- are you connected to VPN?"
end

file = File.open(Rails.application.config.balance_report_location, encoding: "UTF-16")
report = file.read
errors = BalanceReportProcessor.process(data: report)
puts errors.inspect if errors[:unknown].any?

# process the seeds a second time to put in the AAs since they should now exist
LocationLoader.load

# process recurring events
RecurringEventLoader.load
