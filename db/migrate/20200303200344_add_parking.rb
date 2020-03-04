class AddParking < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
    ALTER TYPE estimate_cost_type RENAME TO estimate_cost_type_old;
    CREATE TYPE estimate_cost_type AS ENUM (
      'ground_transportation','lodging','meals','misc','registration','rental_vehicle',
      'air','taxi', 'personal_auto', 'transit_other', 'train', 'parking'
    );  
    ALTER TABLE estimates ALTER COLUMN cost_type TYPE estimate_cost_type USING cost_type::text::estimate_cost_type;
    DROP TYPE estimate_cost_type_old;
  SQL
  end
  
  def down
    execute <<-SQL
      UPDATE estimates SET cost_type = 'transit_other' WHERE cost_type = 'parking';
      ALTER TYPE estimate_cost_type RENAME TO estimate_cost_type_old;
      CREATE TYPE estimate_cost_type AS ENUM (
        'ground_transportation','lodging','meals','misc','registration','rental_vehicle',
        'air','taxi', 'personal_auto', 'transit_other', 'train'
      );  
      ALTER TABLE estimates ALTER COLUMN cost_type TYPE estimate_cost_type USING cost_type::text::estimate_cost_type;
      DROP TYPE estimate_cost_type_old;
    SQL
  end

end
