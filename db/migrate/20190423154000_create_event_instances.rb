class CreateEventInstances < ActiveRecord::Migration[5.2]
  def change
    create_table :event_instances do |t|
      t.belongs_to :event, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.string :location
      t.string :url

      t.timestamps
    end
  end
end
