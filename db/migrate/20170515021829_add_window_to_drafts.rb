class AddWindowToDrafts < ActiveRecord::Migration[5.0]
  def change
    add_column :drafts, :tabId, :string
    add_column :drafts, :windowId, :string
  end
end
