# this migration will destroy data and require the reloading of the departments
class DepartmentAdminAssistant < ActiveRecord::Migration[5.2]
  def up 
    create_join_table :departments, :admin_assistants
    remove_column :departments, :admin_assistant_id
  end

  def down
    drop_join_table :departments, :admin_assistants
    add_reference :departments, :admin_assistant, index: true, foreign_key: {to_table: :staff_profiles}
  end
end
