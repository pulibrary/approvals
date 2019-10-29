# frozen_string_literal: true
every :day, at: "12:20am", roles: [:app] do
  rake "approvals:process_reports"
end
