class ChangeCostTypes < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      ALTER TYPE estimate_cost_type RENAME VALUE 'ground_transportation' TO 'ground transportation';
      ALTER TYPE estimate_cost_type RENAME VALUE 'lodging' TO 'lodging (per night)';
      ALTER TYPE estimate_cost_type RENAME VALUE 'meals' TO 'meals (per diem)';
      ALTER TYPE estimate_cost_type RENAME VALUE 'misc' TO 'miscellaneous';
      ALTER TYPE estimate_cost_type RENAME VALUE 'registration' TO 'registration fee';
      ALTER TYPE estimate_cost_type RENAME VALUE 'rental_vehicle' TO 'car rental';
      ALTER TYPE estimate_cost_type RENAME VALUE 'air' TO 'airfare';
      ALTER TYPE estimate_cost_type RENAME VALUE 'transit_other' TO 'other transit';
    SQL
  end

  def down
    execute <<-SQL
      ALTER TYPE estimate_cost_type RENAME VALUE 'ground transportation' TO 'ground_transportation';
      ALTER TYPE estimate_cost_type RENAME VALUE 'lodging (per night)' TO 'lodging';
      ALTER TYPE estimate_cost_type RENAME VALUE 'meals (per diem)' TO 'meals';
      ALTER TYPE estimate_cost_type RENAME VALUE 'miscellaneous' TO 'misc';
      ALTER TYPE estimate_cost_type RENAME VALUE 'registration fee' TO 'registration';
      ALTER TYPE estimate_cost_type RENAME VALUE 'car rental' TO 'rental_vehicle';
      ALTER TYPE estimate_cost_type RENAME VALUE 'airfare' TO 'air';
      ALTER TYPE estimate_cost_type RENAME VALUE 'other transit' TO 'transit_other';
    SQL
  end
end
