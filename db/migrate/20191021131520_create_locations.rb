class CreateLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :locations do |t|
      t.string :building
      t.bigint :admin_assistant_id, foreign_key: true

      t.timestamps
    end
  end
end
