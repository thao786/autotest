class AddWindowToSteps < ActiveRecord::Migration[5.0]
  def change
    add_column :steps, :tabId, :string
    add_column :steps, :windowId, :string
  end
end
