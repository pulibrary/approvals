class ReportedToRecorded < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      ALTER TYPE request_action RENAME VALUE 'reported' TO 'recorded';
      ALTER TYPE request_status RENAME VALUE 'reported' TO 'recorded';
    SQL
  end

  def down
    execute <<-SQL
      ALTER TYPE request_action RENAME VALUE 'recorded' TO 'reported';
      ALTER TYPE request_status RENAME VALUE 'recorded' TO 'reported';
    SQL
  end
end
