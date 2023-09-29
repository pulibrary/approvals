# frozen_string_literal: true
env :PATH, ENV["PATH"]

# Run at 9:05 am EST or 10:05 EDT (after the 8am staff report is generated)
every :day, at: "02:05 pm", roles: [:app] do
  rake "approvals:process_reports", output: "log/cron.log"
end
