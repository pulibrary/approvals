class ChangeStaffProfileSupervisor < ActiveRecord::Migration[5.2]
  def up
    remove_column :staff_profiles, :supervisor_id, :bigint
    add_reference :staff_profiles, :supervisor, foreign_key: {to_table: :staff_profiles}
  end

  def down
    remove_column :staff_profiles, :supervisor_id, :bigint
    add_reference :staff_profiles, :supervisor, foreign_key: {to_table: :users}
  end
end
