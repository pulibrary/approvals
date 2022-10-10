# frozen_string_literal: true
require "csv"
file = Rails.root.join("public", "request_data.csv")
requests = Request.all
headers = ["creator", "status", "start_date", "end_date", "notes", "request_type"]

CSV.open(file, "w", write_headers: true, headers: headers) do |writer|
    requests.each do |request|
        writer << [request.creator, request.status, request.start_date, request.end_date, request.notes, request.request_type]
    end
end
