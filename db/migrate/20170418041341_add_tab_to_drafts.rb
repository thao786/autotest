class AddTabToDrafts < ActiveRecord::Migration[5.0]
  def change
    add_column :drafts, :chrome_tab, :string
  end
end
