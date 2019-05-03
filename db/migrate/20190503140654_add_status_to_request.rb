class AddStatusToRequest < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE TYPE request_status AS ENUM ('pending', 'pending_department', 'approved', 'denied');
    SQL
    add_column :requests, :status, :request_status
  end

  def down
    remove_column :requests, :status, :request_status
    execute <<-SQL
      DROP TYPE request_status;
    SQL
  end
end
