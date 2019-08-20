class AddNumberToDepartment < ActiveRecord::Migration[5.2]
  def change
    add_column :departments, :number, :string
  end
end
