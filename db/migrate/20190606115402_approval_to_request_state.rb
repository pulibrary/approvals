# This migration will cause loss of data in the state_changes table due to
#  the fact that columns are being removed
class ApprovalToRequestState < ActiveRecord::Migration[5.2]
  def up
    rename_table :approvals, :state_changes
    remove_column :state_changes, :approved, :boolean
    execute <<-SQL
      CREATE TYPE request_action AS ENUM ('approved', 'denied', 'request_changes', 'canceled');
    SQL
    add_column :state_changes, :action, :request_action
  end

  def down
    remove_column :state_changes, :action, :request_action
    execute <<-SQL
      DROP TYPE request_action;
    SQL
    add_column :state_changes, :approved, :boolean
    rename_table :state_changes, :approvals
  end
end
