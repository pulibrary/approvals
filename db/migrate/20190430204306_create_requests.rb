class CreateRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :requests do |t|
      t.bigint :creator_id, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.string :request_type
      t.string :purpose
      t.string :participation
      t.string :travel_category
      t.string :absence_type

      t.timestamps
    end
  end
end
