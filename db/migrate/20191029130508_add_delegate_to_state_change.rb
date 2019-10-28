class AddDelegateToStateChange < ActiveRecord::Migration[5.2]
  def change
    add_reference :state_changes, :delegate, index: true, foreign_key: {to_table: :staff_profiles}
  end
end
