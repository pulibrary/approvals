class CreateStaffProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :staff_profiles do |t|
      t.references :user, foreign_key: true
      t.references :department, foreign_key: true
      t.references :supervisor, foreign_key: {to_table: :users}
      t.boolean :biweekly
      t.string :given_name
      t.string :surname
      t.string :email

      t.timestamps
    end
  end
end
