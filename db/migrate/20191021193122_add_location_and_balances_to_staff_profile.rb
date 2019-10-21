class AddLocationAndBalancesToStaffProfile < ActiveRecord::Migration[5.2]
  def change
    add_reference :staff_profiles, :location, foreign_key: true
    add_column :staff_profiles, :vacation_balance, :decimal  
    add_column :staff_profiles, :sick_balance, :decimal  
    add_column :staff_profiles, :personal_balance, :decimal  
  end
end
