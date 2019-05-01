class CreateDepartments < ActiveRecord::Migration[5.2]
  def change
    create_table :departments do |t|
      t.string :name
      t.bigint :head_id, foreign_key: true
      t.bigint :admin_assistant_id, foreign_key: true

      t.timestamps
    end
  end
end
