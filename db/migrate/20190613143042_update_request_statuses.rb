class UpdateRequestStatuses < ActiveRecord::Migration[5.2]
  def up
    remove_column :requests, :status, :request_status
    execute <<-SQL
      DROP TYPE request_status;
      CREATE TYPE request_status AS ENUM ('approved', 'canceled', 'changes_requested', 'denied', 'pending', 'pending_cancelation', 'reported' );
    SQL
    add_column :requests, :status, :request_status
  end

  def down
    remove_column :requests, :status, :request_status
    execute <<-SQL
      DROP TYPE request_status;
      CREATE TYPE request_status AS ENUM ('pending', 'changes_requested', 'approved', 'denied');
    SQL
    add_column :requests, :status, :request_status
  end
end
