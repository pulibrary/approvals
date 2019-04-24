json.extract! event_instance, :id, :event_id, :start_date, :end_date, :location, :url, :created_at, :updated_at
json.url event_instance_url(event_instance, format: :json)
