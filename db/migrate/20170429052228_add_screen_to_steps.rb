class AddScreenToSteps < ActiveRecord::Migration[5.0]
  def change
    add_column :steps, :screenwidth, :integer
    add_column :steps, :screenheight, :integer
  end
end
