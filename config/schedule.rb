# frozen_string_literal: true
env :PATH, ENV["PATH"]

every :day, at: "12:20am", roles: [:app] do
  rake "approvals:process_reports", output: "log/cron.log"
end
