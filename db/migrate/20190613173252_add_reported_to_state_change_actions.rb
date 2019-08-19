# This migration will cause loss of data in the state_changes table due to
#  the fact that columns are being removed
class AddReportedToStateChangeActions < ActiveRecord::Migration[5.2]
  def up
    remove_column :state_changes, :action, :boolean
    execute <<-SQL
      DROP TYPE request_action;
      CREATE TYPE request_action AS ENUM ('approved', 'canceled', 'changes_requested', 'denied', 'reported');
    SQL
    add_column :state_changes, :action, :request_action
  end

  def down
    remove_column :state_changes, :action, :boolean
    execute <<-SQL
      DROP TYPE request_action;
      CREATE TYPE request_action AS ENUM ('approved', 'denied', 'request_changes', 'canceled');
    SQL
    add_column :state_changes, :action, :request_action
  end
end
