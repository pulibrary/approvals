class RemoveWorkFromHome < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      UPDATE requests SET absence_type = 'consulting' WHERE absence_type = 'work_from_home';
      ALTER TYPE request_absence_type RENAME TO request_absence_type_old;
      CREATE TYPE request_absence_type AS ENUM ('consulting', 'vacation', 'personal', 'sick', 'jury_duty', 'death_in_family', 'research_days');
      ALTER TABLE requests ALTER COLUMN absence_type TYPE request_absence_type USING absence_type::text::request_absence_type;
      DROP TYPE request_absence_type_old;
    SQL
  end
  
  def down
    execute <<-SQL
      ALTER TYPE request_absence_type RENAME TO request_absence_type_old;
      CREATE TYPE request_absence_type AS ENUM ('consulting', 'vacation', 'personal', 'sick', 'jury_duty', 'death_in_family', 'research_days', 'work_from_home');
      ALTER TABLE requests ALTER COLUMN absence_type TYPE request_absence_type USING absence_type::text::request_absence_type;
      DROP TYPE request_absence_type_old;
    SQL
  end
end
