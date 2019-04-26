json.extract! event, :id, :event_id, :start_date, :end_date, :location, :url, :created_at, :updated_at
json.url event_url(event, format: :json)
