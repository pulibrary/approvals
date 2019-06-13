class AddTimesToRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :start_time, :time
    add_column :requests, :end_time, :time
    add_column :requests, :hours_requested, :decimal
  end
end
