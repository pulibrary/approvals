class AddDescriptionToEstimate < ActiveRecord::Migration[5.2]
  def change
    add_column :estimates, :description, :string
  end
end
