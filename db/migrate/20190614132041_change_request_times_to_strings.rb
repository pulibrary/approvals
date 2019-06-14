class ChangeRequestTimesToStrings < ActiveRecord::Migration[5.2]
  def change
    change_column :requests, :start_time, :string
    change_column :requests, :end_time, :string
  end
end
