class RenameMealsPerDiem < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      ALTER TYPE estimate_cost_type RENAME VALUE 'meals (per diem)' TO 'meals and related expenses (daily)';
    SQL
  end

  def down
    execute <<-SQL
      ALTER TYPE estimate_cost_type RENAME VALUE 'meals and related expenses (daily)' TO 'meals (per diem)';
    SQL
  end
end
