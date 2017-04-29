class AddCoordinateToDraft < ActiveRecord::Migration[5.0]
  def change
    add_column :drafts, :x, :integer
    add_column :drafts, :y, :integer
  end
end
