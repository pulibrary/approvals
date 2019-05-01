class AddRequestToEventRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :event_requests, :request_id, :bigint
    add_index :event_requests, :request_id
  end
end
