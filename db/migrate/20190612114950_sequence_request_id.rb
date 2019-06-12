class SequenceRequestId < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      ALTER SEQUENCE requests_id_seq MINVALUE 10000 START WITH 10000 RESTART;
    SQL
  end

  def down
    execute <<-SQL
      ALTER SEQUENCE requests_id_seq NO MINVALUE START WITH 1 RESTART;
    SQL
  end
end

