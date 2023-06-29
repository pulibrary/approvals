class ConvertTravelCategoryToVarchar < ActiveRecord::Migration[6.1]
  def up
    execute <<-END_SQL
      ALTER TABLE requests ALTER COLUMN travel_category TYPE varchar;
      DROP TYPE request_travel_category;
    END_SQL
  end

  def down
    execute <<-END_SQL
      CREATE TYPE request_travel_category AS ENUM ('business', 'professional_development', 'discretionary');
      UPDATE requests SET travel_category = NULL WHERE travel_category NOT IN ('business', 'professional_development', 'discretionary');
      ALTER TABLE requests ALTER COLUMN travel_category TYPE request_travel_category USING (travel_category::request_travel_category);
    END_SQL
  end
end
