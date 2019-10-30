class AddStandardHoursToStaffProfile < ActiveRecord::Migration[5.2]
  def up
    add_column :staff_profiles, :standard_hours_per_week, :decimal  
  end
  def down
    remove_column :staff_profiles, :standard_hours_per_week, :decimal  
  end
end
