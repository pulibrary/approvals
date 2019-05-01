class AddTypeToEstimates < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE TYPE estimate_cost_type AS ENUM ('ground_transportation', 'lodging', 'meals', 'misc', 'registration', 'rental_vehicle', 'air', 'taxi', 'personal_auto', 'transit_other', 'train');
    SQL
    add_column :estimates, :cost_type, :estimate_cost_type
  end

  def down
    remove_column :estimates, :estimate_cost_type
    execute <<-SQL
      DROP TYPE estimate_cost_type;
    SQL
  end
end
