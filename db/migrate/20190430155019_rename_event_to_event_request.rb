class RenameEventToEventRequest < ActiveRecord::Migration[5.2]
  def change
    rename_table :events, :event_requests
  end
end
