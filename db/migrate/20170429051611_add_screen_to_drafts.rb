class AddScreenToDrafts < ActiveRecord::Migration[5.0]
  def change
    def change
      add_column :drafts, :screenwidth, :integer
      add_column :drafts, :screenheight, :integer
    end
  end
end
