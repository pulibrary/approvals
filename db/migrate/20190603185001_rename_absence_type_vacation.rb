class RenameAbsenceTypeVacation < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      ALTER TYPE request_absence_type RENAME VALUE 'vacation_monthly' TO 'vacation';
    SQL
  end

  def down
    execute <<-SQL
      ALTER TYPE request_absence_type RENAME VALUE 'vacation' TO 'vacation_monthly';
    SQL
  end
end
