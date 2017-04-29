class AddParamsToTest < ActiveRecord::Migration[5.0]
  def change
    add_column :tests, :params, :string
  end
end
