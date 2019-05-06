class ChangeRequestStatusValues < ActiveRecord::Migration[5.2]
  def up
    remove_column :requests, :status, :request_status
    execute <<-SQL
      DROP TYPE request_status;
      CREATE TYPE request_status AS ENUM ('pending', 'changes_requested', 'approved', 'denied');
    SQL
    add_column :requests, :status, :request_status
  end

  def down
    remove_column :requests, :status, :request_status
    execute <<-SQL
      DROP TYPE request_status;
      CREATE TYPE request_status AS ENUM ('pending', 'pending_department', 'approved', 'denied');
    SQL
    add_column :requests, :status, :request_status
  end
end
