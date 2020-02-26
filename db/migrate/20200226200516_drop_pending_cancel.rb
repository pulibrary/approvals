class DropPendingCancel < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      UPDATE state_changes SET action = 'canceled' WHERE action = 'pending_cancelation';
      ALTER TYPE request_action RENAME TO request_action_old;
    SQL
    execute <<-SQL
      CREATE TYPE request_action AS ENUM ('approved', 'canceled', 'changes_requested', 'denied', 'recorded', 'pending');
      ALTER TABLE state_changes ALTER COLUMN action TYPE request_action USING action::text::request_action;
      DROP TYPE request_action_old;

      UPDATE requests SET status = 'canceled' WHERE status = 'pending_cancelation';
      ALTER TYPE request_status RENAME TO request_status_old;
      CREATE TYPE request_status AS ENUM ('approved', 'canceled', 'changes_requested', 'denied', 'recorded', 'pending');
      ALTER TABLE requests ALTER COLUMN status TYPE request_status USING status::text::request_status;
      DROP TYPE request_status_old;
    SQL
  end

  def down
    execute <<-SQL
      ALTER TYPE request_action RENAME TO request_action_old;
      CREATE TYPE request_action AS ENUM ('approved', 'canceled', 'changes_requested', 'denied', 'recorded', 'pending_cancelation', 'pending');
      ALTER TABLE state_changes ALTER COLUMN action TYPE request_action USING action::text::request_action;
      DROP TYPE request_action_old;

      ALTER TYPE request_status RENAME TO request_status_old;
      CREATE TYPE request_status AS ENUM ('approved', 'canceled', 'changes_requested', 'denied', 'recorded', 'pending_cancelation', 'pending');
      ALTER TABLE requests ALTER COLUMN status TYPE request_status USING status::text::request_status;
      DROP TYPE request_status_old;
    SQL
  end
end
