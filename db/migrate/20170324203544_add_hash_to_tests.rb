class AddHashToTests < ActiveRecord::Migration[5.0]
  def change
    add_column :tests, :cachesteps, :text
    add_column :tests, :active, :boolean
  end
end
