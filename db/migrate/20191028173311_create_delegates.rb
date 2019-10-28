class CreateDelegates < ActiveRecord::Migration[5.2]
  def change
    create_table :delegates do |t|
      t.references :delegate, index: true, foreign_key: {to_table: :staff_profiles}
      t.references :delegator, index: true, foreign_key: {to_table: :staff_profiles}

      t.timestamps
    end
  end
end
