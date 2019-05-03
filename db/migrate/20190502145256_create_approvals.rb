class CreateApprovals < ActiveRecord::Migration[5.2]
  def change
    create_table :approvals do |t|
      t.bigint :approver_id, foreign_key: true
      t.references :request, foreign_key: true
      t.boolean :approved

      t.timestamps
    end
  end
end
