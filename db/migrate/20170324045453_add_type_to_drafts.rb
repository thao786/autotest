class AddTypeToDrafts < ActiveRecord::Migration[5.0]
  def change
    add_column :drafts, :tag_name, :string
    add_column :drafts, :html_id, :string
    add_column :drafts, :classes, :string
    add_column :drafts, :typed, :string
    add_column :drafts, :scrollTop, :integer
    add_column :drafts, :scrollLeft, :integer
  end
end
