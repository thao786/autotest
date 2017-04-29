class AddHrefToDrafts < ActiveRecord::Migration[5.0]
  def change
    add_column :drafts, :href, :string
    add_column :drafts, :html, :text
  end
end
