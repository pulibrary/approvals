class CreateNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :notes do |t|
      t.belongs_to :request, foreign_key: true
      t.bigint :creator_id, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
