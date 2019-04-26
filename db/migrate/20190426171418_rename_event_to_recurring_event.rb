class RenameEventToRecurringEvent < ActiveRecord::Migration[5.2]
  def change
    rename_table :events, :recurring_events

    rename_column :event_instances, :event_id, :recurring_event_id
  end
end
