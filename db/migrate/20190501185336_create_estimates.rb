class CreateEstimates < ActiveRecord::Migration[5.2]
  def change
    create_table :estimates do |t|
      t.belongs_to :request, foreign_key: true
      t.decimal :amount
      t.integer :recurrence

      t.timestamps
    end
  end
end
