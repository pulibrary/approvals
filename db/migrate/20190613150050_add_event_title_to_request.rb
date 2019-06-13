class AddEventTitleToRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :event_title, :string
  end
end
