class AddOrderToStep < ActiveRecord::Migration[5.0]
  def change
    add_column :steps, :order, :integer
    add_column :steps, :selector, :string
    add_column :steps, :suggestion, :string
  end
end
