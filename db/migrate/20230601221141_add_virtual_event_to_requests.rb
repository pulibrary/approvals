class AddVirtualEventToRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :requests, :virtual_event, :boolean
  end
end
