# frozen_string_literal: true
env :PATH, ENV["PATH"]

# Run at 6:05 am EST or 7:05 EDT (after the 5am staff report is generated)
every :day, at: "11:05 am", roles: [:app] do
  rake "approvals:process_reports", output: "log/cron.log"
end
