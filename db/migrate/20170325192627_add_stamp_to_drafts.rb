class AddStampToDrafts < ActiveRecord::Migration[5.0]
  def change
    add_column :drafts, :stamp, :bigint, :limit => 13
  end
end
