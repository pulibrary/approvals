# This migration will cause loss of data in the requests table due to
#  the fact that columns are being removed
class AddPendingCancelationToStateChange < ActiveRecord::Migration[5.2]
  def up
    remove_column :state_changes, :action, :boolean
    execute <<-SQL
      DROP TYPE request_action;
      CREATE TYPE request_action AS ENUM ('approved', 'canceled', 'changes_requested', 'denied', 'recorded', 'pending_cancelation', 'pending');
    SQL
    add_column :state_changes, :action, :request_action

    rename_column :state_changes, :approver_id, :agent_id
  end

  def down
    remove_column :state_changes, :action, :boolean
    execute <<-SQL
      DROP TYPE request_action;
      CREATE TYPE request_action AS ENUM ('approved', 'canceled', 'changes_requested', 'denied', 'recorded');
    SQL
    add_column :state_changes, :action, :request_action

    rename_column :state_changes, agent_id, :approver_id
  end
end
