class RenameEventInstanceToEvent < ActiveRecord::Migration[5.2]
  def change
    rename_table :event_instances, :events
  end
end
